/**
 * Renders a handful of frames to out/stills/ from ONE bundle, for checking
 * layout and cursor alignment without rendering the whole video.
 *
 *   pnpm stills 770 974 1190
 */
import path from 'node:path';
import { mkdirSync } from 'node:fs';
import { bundle } from '@remotion/bundler';
import { renderStill, selectComposition } from '@remotion/renderer';

const COMPOSITION = 'BackupBrainAd';

async function main(): Promise<void> {
  const frames = process.argv.slice(2).map(Number);
  if (frames.length === 0 || frames.some(Number.isNaN)) throw new Error('Pass frame numbers, e.g. pnpm stills 120 480');

  const { webpackOverride } = await import('../remotion.webpack');
  const serveUrl = await bundle({ entryPoint: path.resolve('src/index.ts'), webpackOverride });
  const composition = await selectComposition({ serveUrl, id: COMPOSITION });
  mkdirSync('out/stills', { recursive: true });

  for (const frame of frames) {
    const output = `out/stills/${String(frame).padStart(5, '0')}.png`;
    await renderStill({ serveUrl, composition, frame, output, scale: 0.5 });
    console.log(`  ${output}`);
  }
}

main().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
