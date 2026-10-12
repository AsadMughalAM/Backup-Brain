import { Audio } from '@remotion/media';
import { Sequence, staticFile } from 'remotion';

/** Vendored from remotion.media, or synthesised by scripts/generate-audio.ts. */
export type SfxName =
  | 'whoosh'
  | 'whip'
  | 'mouse-click'
  | 'ding'
  | 'switch'
  | 'shutter-modern'
  | 'power-down'
  | 'fan-down'
  | 'impact'
  | 'pop'
  | 'riser';

const VOLUME: Record<SfxName, number> = {
  whoosh: 0.32,
  whip: 0.28,
  'mouse-click': 0.45,
  ding: 0.32,
  switch: 0.4,
  'shutter-modern': 0.3,
  'power-down': 0.75,
  'fan-down': 0.35,
  impact: 0.6,
  pop: 0.22,
  riser: 0.3,
};

/** A short sound at frame `at`, quiet enough to sit under the voice. */
export function Sfx({ name, at }: { name: SfxName; at: number }): React.JSX.Element {
  return (
    <Sequence from={Math.max(0, Math.round(at))} durationInFrames={75} layout="none" name={`sfx:${name}`}>
      <Audio src={staticFile(`sfx/${name}.wav`)} volume={VOLUME[name]} />
    </Sequence>
  );
}
