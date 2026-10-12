/**
 * Loudness-normalises the render to -14 LUFS (the Reels / TikTok / YouTube
 * target), using the ffmpeg Remotion ships. Writes two files from out/raw.mp4:
 *   out/backup-brain-ad.mp4          AAC, for upload
 *   out/backup-brain-ad-preview.mp4  MP3, plays with sound in VS Code's preview
 */
import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
import path from 'node:path';
import { rmSync } from 'node:fs';

// The compositor is the renderer's own dependency, so resolve it from there (pnpm doesn't hoist it).
const fromRenderer = createRequire(createRequire(import.meta.url).resolve('@remotion/renderer'));
const compositorDir = path.dirname(fromRenderer.resolve('@remotion/compositor-win32-x64-msvc/package.json'));
const FFMPEG = path.join(compositorDir, 'ffmpeg.exe');
const RAW = 'out/raw.mp4';
const LOUDNORM = 'loudnorm=I=-14:TP=-1:LRA=11';

const outputs = [
  { file: 'out/backup-brain-ad.mp4', codec: 'aac' },
  { file: 'out/backup-brain-ad-preview.mp4', codec: 'libmp3lame' },
];

for (const { file, codec } of outputs) {
  execFileSync(FFMPEG, ['-v', 'error', '-y', '-i', RAW, '-c:v', 'copy', '-af', LOUDNORM, '-ar', '48000', '-c:a', codec, '-b:a', '256k', file], {
    stdio: 'inherit',
  });
  console.log(`  ${file}`);
}
rmSync(RAW);
