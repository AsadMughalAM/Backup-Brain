import durations from './voiceover/durations.json';
import { VOICE_LINES, type VoiceLineId } from './voiceover/lines';
import { VIDEO } from './theme';

/** Silence before a line starts inside its scene, and after it ends. */
const LEAD = 8;
const TAIL = 12;
/** Scenes that need room before the voice: the hook plays the blackout first. */
const LEADS: Partial<Record<VoiceLineId, number>> = { hook: 54 };
/** Scenes whose choreography needs longer than the line takes to say. */
const MIN_FRAMES: Partial<Record<VoiceLineId, number>> = {
  overload: 170,
  planner: 230,
  ask: 150,
  outro: 165,
};

export const SCENE_IDS = VOICE_LINES.map((l) => l.id);

export function lead(id: VoiceLineId): number {
  return LEADS[id] ?? LEAD;
}

export function audioFrames(id: VoiceLineId): number {
  return Math.ceil((durations as Record<string, number>)[id] * VIDEO.fps);
}

export function sceneLength(id: VoiceLineId): number {
  return Math.max(MIN_FRAMES[id] ?? 0, lead(id) + audioFrames(id) + TAIL);
}

export function sceneStart(id: VoiceLineId): number {
  let start = 0;
  for (const scene of SCENE_IDS) {
    if (scene === id) return start;
    start += sceneLength(scene);
  }
  throw new Error(`Unknown scene "${id}"`);
}

export const TOTAL_FRAMES = SCENE_IDS.reduce((sum, id) => sum + sceneLength(id), 0);

/**
 * Frame inside the scene when `phrase` is spoken, estimated from where it sits
 * in the line. Visual beats hang off these, never off absolute frames.
 */
export function spokenAt(id: VoiceLineId, phrase: string): number {
  const text = VOICE_LINES.find((l) => l.id === id)?.text ?? '';
  const index = text.indexOf(phrase);
  if (index < 0) throw new Error(`"${phrase}" is not in line "${id}"`);
  return Math.round(lead(id) + (index / text.length) * audioFrames(id));
}
