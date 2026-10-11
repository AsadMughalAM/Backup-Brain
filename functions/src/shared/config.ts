/** Same region as Firestore, close to Pakistan. */
export const REGION = 'asia-south1';

export const GEMINI_MODEL = 'gemini-3.1-flash-lite';

/** Assistant messages per user per Pakistan day: protects the AI budget. */
export const DAILY_MESSAGE_LIMIT = 50;

/** Pakistan has no daylight saving: always UTC+5. */
const PKT_OFFSET_MS = 5 * 60 * 60 * 1000;

/** "2026-10-11" in Pakistan time. */
export const pakistanDay = (now: Date = new Date()): string =>
  new Date(now.getTime() + PKT_OFFSET_MS).toISOString().slice(0, 10);
