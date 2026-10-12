/**
 * Generates the narration locally with Kokoro-82M (Apache 2.0, runs on CPU,
 * no API key, nothing leaves the machine).
 *
 *   pnpm voiceover            all lines
 *   pnpm voiceover send ask   only these ids
 *
 * Writes public/voiceover/<id>.wav and records each clip's length in
 * src/voiceover/durations.json, which the timeline reads to size every beat.
 */
import { mkdirSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
import { KokoroTTS } from 'kokoro-js';
import { VOICE_LINES } from '../src/voiceover/lines';

const MODEL_ID = 'onnx-community/Kokoro-82M-v1.0-ONNX';
// af_heart is Kokoro's highest-graded English voice: warm, clear, unhurried.
const VOICE = (process.env.VOICE ?? 'af_heart') as 'af_heart';
const SPEED = Number(process.env.SPEED ?? 1);
const OUT_DIR = 'public/voiceover';
const DURATIONS_FILE = 'src/voiceover/durations.json';

async function main(): Promise<void> {
  const only = new Set(process.argv.slice(2));
  const lines = VOICE_LINES.filter((l) => only.size === 0 || only.has(l.id));
  if (lines.length === 0) throw new Error(`No voice lines match: ${[...only].join(', ')}`);

  mkdirSync(OUT_DIR, { recursive: true });
  const durations: Record<string, number> = existsSync(DURATIONS_FILE)
    ? JSON.parse(readFileSync(DURATIONS_FILE, 'utf8'))
    : {};

  console.log(`Loading ${MODEL_ID} (first run downloads ~90 MB)…`);
  const tts = await KokoroTTS.from_pretrained(MODEL_ID, { dtype: 'q8', device: 'cpu' });

  for (const line of lines) {
    const spoken = 'spoken' in line ? line.spoken : line.text;
    const audio = await tts.generate(spoken, { voice: VOICE, speed: SPEED });
    await audio.save(`${OUT_DIR}/${line.id}.wav`);
    const seconds = audio.audio.length / audio.sampling_rate;
    durations[line.id] = Math.round(seconds * 1000) / 1000;
    console.log(`  ${line.id.padEnd(11)} ${seconds.toFixed(2)}s`);
  }

  writeFileSync(DURATIONS_FILE, `${JSON.stringify(durations, null, 2)}\n`);
  console.log(`Wrote ${DURATIONS_FILE}`);
}

main().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
