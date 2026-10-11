import { z } from 'zod';

/** The app trims history to this many turns; anything longer is abuse. */
const MAX_TURNS = 12;
const MAX_TEXT = 2000;
const MAX_SNAPSHOT_CHARS = 8000;

export const assistantChatInput = z.object({
  messages: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant']),
        text: z.string().trim().min(1).max(MAX_TEXT),
      }),
    )
    .min(1)
    .max(MAX_TURNS)
    .refine((m) => m.at(-1)?.role === 'user', 'The last message must be the user’s.'),
  // Engine output from the app (TECH_STACK §3.1). Only its size is checked:
  // the model is told to treat it as the household's numbers, nothing more.
  snapshot: z
    .record(z.string(), z.unknown())
    .refine((s) => JSON.stringify(s).length <= MAX_SNAPSHOT_CHARS, 'Snapshot too large.'),
  language: z.enum(['en', 'ur_Latn']),
});

export type AssistantChatInput = z.infer<typeof assistantChatInput>;
