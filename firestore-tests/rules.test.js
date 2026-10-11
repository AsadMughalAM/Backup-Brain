// Security rules tests (TECH_STACK.md §7.4). Run: `pnpm test` in this folder.
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { afterAll, beforeAll, beforeEach, describe, test } from 'vitest';

let env;

const system = {
  hasSolar: false,
  inverter: { type: 'hybrid', ratedW: 2000, efficiency: 0.9 },
  battery: { chemistry: 'lifepo4', voltage: 24, ah: 150, count: 1 },
  soc: 0.6,
};

const solar = { kWp: 2.16, panelW: 540, panelCount: 4, shading: 'none' };
const location = { city: 'Lahore', lat: 31.5204, lon: 74.3587 };

const appliance = {
  name: 'Ceiling fan',
  watts: 75,
  quantity: 1,
  dutyCycle: 1,
  priority: 'comfort',
  isOn: true,
};

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-backup-brain',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

afterAll(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const db = (uid) =>
  uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();

describe('users/{uid}', () => {
  test('owner can write and read their system', async () => {
    const ref = db('alice').doc('users/alice/systems/main');
    await assertSucceeds(ref.set(system));
    await assertSucceeds(ref.get());
  });

  test('another user cannot read or write it', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      ctx.firestore().doc('users/alice/systems/main').set(system),
    );
    await assertFails(db('bob').doc('users/alice/systems/main').get());
    await assertFails(db('bob').doc('users/alice/systems/main').set(system));
  });

  test('signed-out users get nothing', async () => {
    await assertFails(db(null).doc('users/alice/systems/main').get());
    await assertFails(db(null).doc('users/alice').set({ name: 'x' }));
  });

  test('owner can write the profile document', async () => {
    await assertSucceeds(db('alice').doc('users/alice').set({ language: 'en' }));
  });
});

describe('validation', () => {
  test('rejects a system with a bad chemistry, SoC or count', async () => {
    const ref = db('alice').doc('users/alice/systems/main');
    await assertFails(ref.set({ ...system, battery: { ...system.battery, chemistry: 'nicad' } }));
    await assertFails(ref.set({ ...system, soc: 60 }));
    await assertFails(ref.set({ ...system, battery: { ...system.battery, count: 0 } }));
  });

  test('accepts solar panels and a location (the demo household)', async () => {
    const ref = db('alice').doc('users/alice/systems/main');
    await assertSucceeds(ref.set({ ...system, hasSolar: true, solar, location }));
  });

  test('rejects bad panels or coordinates', async () => {
    const ref = db('alice').doc('users/alice/systems/main');
    await assertFails(ref.set({ ...system, solar: { ...solar, kWp: 0 } }));
    await assertFails(ref.set({ ...system, solar: { ...solar, shading: 'some' } }));
    await assertFails(ref.set({ ...system, location: { ...location, lat: 95 } }));
    await assertFails(ref.set({ ...system, location: { ...location, city: '' } }));
  });

  test("the battery's known charge and its time, and a panel cleaning", async () => {
    const ref = db('alice').doc('users/alice/systems/main');
    await assertSucceeds(ref.set({ ...system, hasSolar: true, solar, location }));
    await assertSucceeds(ref.update({ soc: 0.45, socAt: new Date() }));
    await assertSucceeds(ref.update({ soc: 0.75, socAt: new Date(), socCheckedAt: new Date() }));
    await assertSucceeds(ref.update({ 'solar.lastCleanedAt': new Date() }));
    await assertFails(ref.update({ socAt: 'now' }));
    await assertFails(ref.update({ socCheckedAt: 1728600000 }));
    await assertFails(ref.update({ 'solar.lastCleanedAt': 'yesterday' }));
  });

  test('appliance watts can be changed, never to nonsense', async () => {
    const ref = db('alice').doc('users/alice/systems/main/appliances/fan');
    await assertSucceeds(ref.set(appliance));
    await assertSucceeds(ref.update({ watts: 35 }));
    await assertFails(ref.update({ watts: -35 }));
  });

  test('a logged outage can be moved or deleted by its owner only', async () => {
    const ref = db('alice').doc('users/alice/systems/main/outages/o2');
    await assertSucceeds(ref.set({ startedAt: new Date(), source: 'manual' }));
    await assertSucceeds(ref.update({ startedAt: new Date(Date.now() - 30 * 60000) }));
    await assertFails(db('bob').doc('users/alice/systems/main/outages/o2').delete());
    await assertSucceeds(ref.delete());
  });

  test('the weather cache is owner-only', async () => {
    const ref = db('alice').doc('users/alice/systems/main/weatherCache/2026-10-11');
    await assertSucceeds(ref.set({ lat: 31.52, lon: 74.36 }));
    await assertFails(db('bob').doc('users/alice/systems/main/weatherCache/2026-10-11').get());
  });

  test('accepts a valid appliance and an isOn toggle', async () => {
    const ref = db('alice').doc('users/alice/systems/main/appliances/fan');
    await assertSucceeds(ref.set(appliance));
    await assertSucceeds(ref.update({ isOn: false }));
  });

  test('rejects appliances with bad fields', async () => {
    const ref = db('alice').doc('users/alice/systems/main/appliances/fan');
    await assertFails(ref.set({ ...appliance, watts: -5 }));
    await assertFails(ref.set({ ...appliance, dutyCycle: 0 }));
    await assertFails(ref.set({ ...appliance, priority: 'urgent' }));
    await assertFails(ref.set({ ...appliance, isOn: 'yes' }));
    await assertFails(ref.set({ ...appliance, name: '' }));
  });

  test('outages are validated and owner-only', async () => {
    const ref = db('alice').doc('users/alice/systems/main/outages/o1');
    await assertSucceeds(ref.set({ startedAt: new Date(), source: 'manual', startSoC: 0.6 }));
    await assertSucceeds(ref.update({ endedAt: new Date(), endSoC: 0.45 }));
    await assertFails(ref.set({ startedAt: 'today', source: 'manual' }));
    await assertFails(ref.set({ startedAt: new Date(), source: 'guess' }));
    await assertFails(ref.set({ startedAt: new Date(), source: 'manual', endSoC: 45 }));
    await assertSucceeds(ref.update({ endSoC: 0.4, endSoCSource: 'user' }));
    await assertFails(ref.update({ endSoCSource: 'guess' }));
    await assertFails(db('bob').doc('users/alice/systems/main/outages/o1').get());
  });

  test('schedule slots are validated', async () => {
    const ref = db('alice').doc('users/alice/systems/main/schedule/s1');
    await assertSucceeds(ref.set({ weekday: 7, startMinute: 1140, endMinute: 1260 }));
    await assertFails(ref.set({ weekday: 8, startMinute: 1140, endMinute: 1260 }));
    await assertFails(ref.set({ weekday: 1, startMinute: 1440, endMinute: 60 }));
  });

  test('solar logs are validated and owner-only', async () => {
    const ref = db('alice').doc('users/alice/systems/main/solarLogs/2026-10-11');
    await assertSucceeds(ref.set({ date: '2026-10-11', actualKWh: 8.2, expectedKWh: 9.6, clearShare: 0.9 }));
    await assertFails(ref.set({ date: '2026-10-11', actualKWh: -1, expectedKWh: 9.6 }));
    await assertFails(ref.set({ expectedKWh: 4 }));
    await assertFails(db('bob').doc('users/alice/systems/main/solarLogs/2026-10-11').get());
  });

  test('other per-system logs are owner-only', async () => {
    const ref = db('alice').doc('users/alice/systems/main/healthSnapshots/h1');
    await assertSucceeds(ref.set({ healthFactor: 0.8 }));
    await assertFails(db('bob').doc('users/alice/systems/main/healthSnapshots/h1').get());
  });
});

describe('reference data', () => {
  test('signed-in users can read config and catalog, nobody writes', async () => {
    await assertSucceeds(db('alice').doc('config/pricing_pk').get());
    await assertSucceeds(db('alice').doc('batteryCatalog/b1').get());
    await assertFails(db('alice').doc('config/pricing_pk').set({ x: 1 }));
    await assertFails(db('alice').doc('batteryCatalog/b1').set({ x: 1 }));
  });

  test('signed-out users cannot read config', async () => {
    await assertFails(db(null).doc('config/pricing_pk').get());
  });

  test('users cannot read or reset their own AI usage counter', async () => {
    await assertFails(db('alice').doc('aiUsage/alice').get());
    await assertFails(db('alice').doc('aiUsage/alice').set({ day: '2026-10-11', count: 0 }));
  });

  test('unknown top-level collections are denied', async () => {
    await assertFails(db('alice').doc('secrets/x').get());
  });
});
