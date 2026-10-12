/**
 * The narration, one line per scene. The single source for the voiceover
 * generator (public/voiceover/<id>.wav) and the on-screen captions, so what is
 * heard and what is read never drift.
 *
 * `spoken` only exists where the TTS needs help saying something the way a
 * Pakistani household would ("UPS" spelled out, numbers in words).
 */
export interface VoiceLine {
  id: string;
  text: string;
  spoken?: string;
}

export const VOICE_LINES = [
  {
    id: 'hook',
    text: "The light's gone again. The UPS says 60%. But how long is that, really?",
    spoken: "The light's gone again. The U P S says sixty percent. But how long is that, really?",
  },
  {
    id: 'countdown',
    text: "Backup Brain turns that percent into time. 3 hours 28 minutes, at what's running right now.",
    spoken: "Backup Brain turns that percent into time. Three hours, twenty eight minutes, at what's running right now.",
  },
  {
    id: 'overload',
    text: 'Switch on the iron and the water motor, and it warns you before the inverter trips.',
  },
  {
    id: 'planner',
    text: "Need it to last longer? It ranks what to turn off first. Two taps, and you're at 5 hours 49.",
    spoken: "Need it to last longer? It ranks what to turn off first. Two taps, and you're at five hours forty nine.",
  },
  {
    id: 'ready',
    text: "It checks tomorrow's sun and your area's schedule, and warns you before the next cut if the battery won't be ready.",
  },
  {
    id: 'more',
    text: 'Thinking about solar? See the cost and savings first. Battery wearing out? Find out why, which one to buy, and shops near you.',
  },
  {
    id: 'ask',
    text: 'And ask it anything, in English or Roman Urdu.',
  },
  {
    id: 'outro',
    text: 'Backup Brain. Know how long your backup lasts, before the light goes.',
  },
] as const satisfies readonly VoiceLine[];

export type VoiceLineId = (typeof VOICE_LINES)[number]['id'];
