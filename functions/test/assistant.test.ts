import { describe, expect, it } from 'vitest';

import { buildSystemPrompt } from '../src/assistant/prompt.js';
import { assistantChatInput } from '../src/assistant/schema.js';
import { pakistanDay } from '../src/shared/config.js';
import { nextUsage } from '../src/shared/quota.js';

const valid = {
  messages: [{ role: 'user', text: 'Kitni der chalegi battery?' }],
  snapshot: { now: { backupTimeLeft: '3h 28m' } },
  language: 'ur_Latn',
};

describe('assistantChat input', () => {
  it('accepts what the app sends', () => {
    expect(assistantChatInput.safeParse(valid).success).toBe(true);
  });

  it('rejects a history that ends with the assistant', () => {
    const input = {
      ...valid,
      messages: [...valid.messages, { role: 'assistant', text: 'Hi' }],
    };
    expect(assistantChatInput.safeParse(input).success).toBe(false);
  });

  it('rejects an oversized snapshot and unknown languages', () => {
    expect(
      assistantChatInput.safeParse({ ...valid, snapshot: { x: 'a'.repeat(9000) } }).success,
    ).toBe(false);
    expect(assistantChatInput.safeParse({ ...valid, language: 'fr' }).success).toBe(false);
  });
});

describe('system prompt', () => {
  it('forbids new numbers and carries the snapshot', () => {
    const prompt = buildSystemPrompt(valid.snapshot, 'ur_Latn');
    expect(prompt).toContain('Never calculate');
    expect(prompt).toContain('"backupTimeLeft": "3h 28m"');
    expect(prompt).toContain('Roman Urdu');
  });
});

describe('daily quota', () => {
  it('counts up within a day and resets the next day', () => {
    expect(nextUsage(undefined, '2026-10-11', 2)).toEqual({ day: '2026-10-11', count: 1 });
    expect(nextUsage({ day: '2026-10-11', count: 1 }, '2026-10-11', 2)).toEqual({
      day: '2026-10-11',
      count: 2,
    });
    expect(nextUsage({ day: '2026-10-11', count: 2 }, '2026-10-11', 2)).toBeNull();
    expect(nextUsage({ day: '2026-10-11', count: 2 }, '2026-10-12', 2)).toEqual({
      day: '2026-10-12',
      count: 1,
    });
  });

  it('uses the Pakistan day, not UTC', () => {
    // 20:00 UTC on the 11th is already 01:00 on the 12th in Pakistan.
    expect(pakistanDay(new Date('2026-10-11T20:00:00Z'))).toBe('2026-10-12');
  });
});
