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

  test('other per-system logs are owner-only, not appliance-validated', async () => {
    const ref = db('alice').doc('users/alice/systems/main/outages/o1');
    await assertSucceeds(ref.set({ source: 'manual' }));
    await assertFails(db('bob').doc('users/alice/systems/main/outages/o1').get());
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

  test('unknown top-level collections are denied', async () => {
    await assertFails(db('alice').doc('secrets/x').get());
  });
});
