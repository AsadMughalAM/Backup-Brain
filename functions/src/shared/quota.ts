import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';

import { DAILY_MESSAGE_LIMIT, pakistanDay } from './config.js';

export interface Usage {
  day: string;
  count: number;
}

/** The usage after one more message, or null when today's limit is used up. */
export function nextUsage(
  previous: Partial<Usage> | undefined,
  today: string,
  limit: number,
): Usage | null {
  const count = previous?.day === today ? (previous.count ?? 0) : 0;
  return count >= limit ? null : { day: today, count: count + 1 };
}

/**
 * Counts one assistant message for [uid]. Stored in top-level `aiUsage`,
 * which the rules deny to clients, so a user can't reset their own count.
 */
export async function consumeDailyQuota(uid: string): Promise<void> {
  const db = getFirestore();
  const ref = db.doc(`aiUsage/${uid}`);
  const allowed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const next = nextUsage(
      snap.data() as Partial<Usage> | undefined,
      pakistanDay(),
      DAILY_MESSAGE_LIMIT,
    );
    if (next === null) return false;
    tx.set(ref, next);
    return true;
  });
  if (!allowed) {
    throw new HttpsError('resource-exhausted', 'Daily assistant limit reached.');
  }
}
