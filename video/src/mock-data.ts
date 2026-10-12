import demo from '@app/assets/data/demo_household.json';
import { t } from './copy';

/**
 * The demo household (app/assets/data/demo_household.json) and the numbers the
 * engine produces for it. Each value is locked by an energy_engine test or
 * follows from the same usable energy (1458 Wh at 60%), so the ad shows what
 * the app shows. Shop names are fictional.
 */
export type ApplianceId = (typeof demo.appliances)[number]['id'];

export function appliance(id: ApplianceId) {
  const found = demo.appliances.find((a) => a.id === id);
  if (!found) throw new Error(`No demo appliance "${id}"`);
  return found;
}

export const INVERTER_W = demo.system.inverter.ratedW;
export const CITY = demo.system.location.city;
export const BATTERY_PERCENT = demo.system.soc * 100;

/** Backup in whole minutes at a given load (backup_calculator_test, load_planner_test). */
export const BACKUP_MINUTES = {
  at420: 208, // 3h 28m, the demo's headline
  at1420: 61, // iron on
  at2170: 40, // iron and motor on: overload
  at330: 265, // TV off
  at250: 349, // TV and fridge off: 5h 49m
} as const;

/**
 * The Turn off first list (load_planner_test order), with each row's gain in
 * minutes against the current load. Gains are re-ranked after every switch-off,
 * so each step has its own column: 420 W, then 330 W (TV off), then 250 W.
 */
export const TURN_OFF_FIRST = [
  { id: 'tv', gain: [56, 0, 0] },
  { id: 'fridge', gain: [49, 84, 0] },
  { id: 'fan-bedroom', gain: [45, 77, 149] },
  { id: 'fan-lounge', gain: [45, 77, 149] },
  { id: 'laptop', gain: [21, 36, 66] },
] as const satisfies readonly { id: ApplianceId; gain: readonly [number, number, number] }[];

export const LOADS = { normal: 420, iron: 1420, overload: 2170, tvOff: 330, twoOff: 250 } as const;

/** Solar fixture of 11 Oct 2026 (solar_model_test). */
export const SOLAR = {
  reachesPercent: 79,
  startPercent: 60,
  sunset: '5:30 PM',
  lessSunPercent: 49,
  rangeKWh: '3.3–4.5',
  lastsUntil: '10:25 PM',
  /** Relative sun per hour from 6 AM to 6 PM, forecast against a clear day. */
  hours: [
    [0.04, 0.08],
    [0.14, 0.3],
    [0.24, 0.52],
    [0.33, 0.72],
    [0.45, 0.86],
    [0.52, 0.95],
    [0.55, 1],
    [0.5, 0.97],
    [0.44, 0.88],
    [0.32, 0.72],
    [0.2, 0.5],
    [0.1, 0.27],
    [0.03, 0.08],
  ],
} as const;

/** A scheduled cut the battery won't cover: alertBodyShort. 50% → 1134 Wh → 2h 40m (10 min steps). */
export const ALERT = { time: '7:00 PM', soc: '50%', backup: '2h 40m', outage: '3h 30m' } as const;

/** 400 units a month in Lahore (solar_sizing_test, pricing_pk.json tariff Rs 50). */
export const ESTIMATE = { units: 415, savings: '20,000' } as const;

/** Battery health after a simulated year (ARCHITECTURE §12 step 6). */
export const HEALTH = { now: '2.9', label: '3.6', loss: '18%' } as const;

export const SHOPS = [
  { name: 'Al-Noor Battery House', distance: '0.8 km', area: 'Model Town' },
  { name: 'Hamza UPS & Solar', distance: '1.4 km', area: 'Faisal Town' },
] as const;

export const CHAT = {
  question: 'Raat 2 baje tak fan chal sakta hai?',
  // 1458 Wh at 85 W (one fan and the router) is about 17 hours.
  answer: 'Haan. Sirf ek fan aur Wi-Fi on hon (85 W) to battery takreeban 17 ghante chalegi.',
} as const;

/** The app's own duration format: "3h 28m", or "40m" under an hour. */
export function duration(totalMinutes: number): string {
  const whole = Math.max(0, Math.floor(totalMinutes));
  const hours = Math.floor(whole / 60);
  const minutes = whole % 60;
  return hours === 0 ? t('durationMinutes', { minutes }) : t('durationHoursMinutes', { hours, minutes });
}

export const watts = (w: number) => `${Math.round(w).toLocaleString('en')} W`;
