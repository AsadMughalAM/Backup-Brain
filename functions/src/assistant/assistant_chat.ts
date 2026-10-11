import { GoogleGenAI } from '@google/genai';
import { getApps, initializeApp } from 'firebase-admin/app';
import { defineSecret } from 'firebase-functions/params';
import { logger } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import { GEMINI_MODEL, REGION } from '../shared/config.js';
import { consumeDailyQuota } from '../shared/quota.js';
import { buildSystemPrompt } from './prompt.js';
import { assistantChatInput } from './schema.js';

if (getApps().length === 0) initializeApp();

/** Set with `firebase functions:secrets:set GEMINI_API_KEY`; never in git. */
const geminiApiKey = defineSecret('GEMINI_API_KEY');

/**
 * F9: `{messages, snapshot, language}` → `{reply}` (TECH_STACK §3.2).
 * Signed-in users only, validated input, a daily limit per user.
 */
export const assistantChat = onCall(
  {
    region: REGION,
    secrets: [geminiApiKey],
    timeoutSeconds: 60,
    memory: '256MiB',
    maxInstances: 10,
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');

    const parsed = assistantChatInput.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError('invalid-argument', parsed.error.message);
    }
    const { messages, snapshot, language } = parsed.data;

    await consumeDailyQuota(uid);

    let text: string | undefined;
    try {
      const ai = new GoogleGenAI({ apiKey: geminiApiKey.value() });
      const response = await ai.models.generateContent({
        model: GEMINI_MODEL,
        contents: messages.map((m) => ({
          role: m.role === 'user' ? 'user' : 'model',
          parts: [{ text: m.text }],
        })),
        config: {
          systemInstruction: buildSystemPrompt(snapshot, language),
          temperature: 0.2,
          maxOutputTokens: 600,
        },
      });
      text = response.text;
    } catch (error) {
      logger.error('Gemini call failed', { uid, error: String(error) });
      // `internal`: the app shows "assistant unavailable", not "no internet".
      throw new HttpsError('internal', 'The assistant could not answer.');
    }

    const reply = text?.replaceAll('**', '').trim();
    if (!reply) throw new HttpsError('internal', 'The assistant gave no answer.');
    return { reply };
  },
);
