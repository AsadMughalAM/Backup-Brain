/**
 * Synthesises the music bed and the sounds remotion.media does not have, so the
 * whole soundtrack is free, offline and reproducible.
 *
 *   pnpm audio
 *
 * Writes public/music/bed.wav and public/sfx/{power-down,fan-down,impact,pop,riser}.wav.
 */
import { mkdirSync, writeFileSync } from 'node:fs';

const RATE = 44100;
const TAU = Math.PI * 2;

function wav(samples: Float32Array): Buffer {
  const peak = samples.reduce((m, s) => Math.max(m, Math.abs(s)), 0) || 1;
  const gain = 0.7 / peak; // about -3 dB, leaves room under the voice
  const data = Buffer.alloc(samples.length * 2);
  samples.forEach((s, i) => data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, s * gain)) * 32767), i * 2));
  const header = Buffer.alloc(44);
  header.write('RIFF', 0);
  header.writeUInt32LE(36 + data.length, 4);
  header.write('WAVEfmt ', 8);
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(1, 22);
  header.writeUInt32LE(RATE, 24);
  header.writeUInt32LE(RATE * 2, 28);
  header.writeUInt16LE(2, 32);
  header.writeUInt16LE(16, 34);
  header.write('data', 36);
  header.writeUInt32LE(data.length, 40);
  return Buffer.concat([header, data]);
}

function render(seconds: number, sample: (t: number) => number): Float32Array {
  const out = new Float32Array(Math.round(seconds * RATE));
  for (let i = 0; i < out.length; i++) out[i] = sample(i / RATE);
  return out;
}

// Deterministic noise so every run writes the same files.
let seed = 7;
function noise(): number {
  seed = (seed * 16807) % 2147483647;
  return (seed / 2147483647) * 2 - 1;
}

const hz = (midi: number) => 440 * 2 ** ((midi - 69) / 12);

/** Phase-accumulated sweep, so pitch glides don't click. */
function sweep(seconds: number, from: number, to: number, shape: (t: number) => number): Float32Array {
  let phase = 0;
  return render(seconds, (t) => {
    const f = from * (to / from) ** (t / seconds);
    phase += (TAU * f) / RATE;
    return Math.sin(phase) * shape(t);
  });
}

function mix(...layers: Float32Array[]): Float32Array {
  const out = new Float32Array(Math.max(...layers.map((l) => l.length)));
  for (const layer of layers) layer.forEach((s, i) => (out[i] += s));
  return out;
}

// --- Music bed: 96 BPM, Am F C G, a pulse that builds -----------------------
const BPM = 96;
const BEAT = 60 / BPM;
const BAR = BEAT * 4;
const CHORDS = [
  [57, 60, 64],
  [53, 57, 60],
  [48, 55, 64],
  [55, 59, 62],
];

function bed(seconds: number): Float32Array {
  return render(seconds, (t) => {
    const beatPos = t / BEAT;
    const sinceBeat = (beatPos % 1) * BEAT;
    const chord = CHORDS[Math.floor(t / (BAR * 2)) % CHORDS.length];
    const build = Math.min(1, t / 8); // pad first, pulse grows in over 8 s

    const kickPhase = TAU * (45 * sinceBeat + (105 / 18) * (1 - Math.exp(-18 * sinceBeat)));
    const kick = Math.sin(kickPhase) * Math.exp(-7 * sinceBeat) * build;
    const pump = 1 - 0.55 * Math.exp(-9 * sinceBeat) * build;

    let pad = 0;
    for (const note of chord) {
      const f = hz(note);
      pad += Math.sin(TAU * f * t) + 0.35 * Math.sin(TAU * f * 2.003 * t) + 0.12 * Math.sin(TAU * f * 3 * t);
    }
    pad *= 0.11 * (0.85 + 0.15 * Math.sin(TAU * 0.25 * t));

    const eighth = Math.floor(t / (BEAT / 2));
    const sinceEighth = t % (BEAT / 2);
    const arpNote = chord[eighth % 3] + 12;
    const pluck = Math.sin(TAU * hz(arpNote) * t) * Math.exp(-14 * sinceEighth) * 0.16 * Math.max(0, build * 1.4 - 0.4);

    const offbeat = ((beatPos + 0.5) % 1) * BEAT;
    const hat = noise() * Math.exp(-90 * offbeat) * 0.09 * Math.max(0, build * 2 - 1);

    return kick * 0.9 + pad * pump + pluck * pump + hat;
  });
}

// --- Sound effects -------------------------------------------------------------
const powerDown = () =>
  mix(
    sweep(1.1, 220, 32, (t) => Math.exp(-2.6 * t)),
    sweep(0.4, 90, 40, (t) => Math.exp(-9 * t) * 1.2),
    render(0.08, (t) => noise() * Math.exp(-50 * t) * 0.6),
  );

/** Filtered noise chopped at the blade rate, both slowing to a stop. */
function fanDown(): Float32Array {
  let low = 0;
  let phase = 0;
  return render(2.2, (t) => {
    low += 0.04 * (noise() - low);
    phase += (TAU * (11 * Math.exp(-1.1 * t) + 0.5)) / RATE;
    return low * 4 * (0.55 + 0.45 * Math.sin(phase)) * Math.max(0, 1 - t / 2.2);
  });
}

const impact = () =>
  mix(
    sweep(0.6, 95, 38, (t) => Math.exp(-6 * t)),
    render(0.05, (t) => noise() * Math.exp(-70 * t) * 0.8),
  );

const pop = () => sweep(0.09, 520, 980, (t) => Math.sin((Math.PI * t) / 0.09));

function riser(): Float32Array {
  let low = 0;
  const air = render(1.3, (t) => {
    low += (0.02 + 0.3 * (t / 1.3)) * (noise() - low);
    return low * (t / 1.3) ** 2;
  });
  return mix(air, sweep(1.3, 180, 720, (t) => 0.35 * (t / 1.3) ** 2));
}

mkdirSync('public/music', { recursive: true });
mkdirSync('public/sfx', { recursive: true });
const files: Record<string, Float32Array> = {
  'public/music/bed.wav': bed(60),
  'public/sfx/power-down.wav': powerDown(),
  'public/sfx/fan-down.wav': fanDown(),
  'public/sfx/impact.wav': impact(),
  'public/sfx/pop.wav': pop(),
  'public/sfx/riser.wav': riser(),
};
for (const [path, samples] of Object.entries(files)) {
  writeFileSync(path, wav(samples));
  console.log(`  ${path}  ${(samples.length / RATE).toFixed(2)}s`);
}
