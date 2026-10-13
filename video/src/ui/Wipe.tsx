import { AbsoluteFill, useCurrentFrame } from 'remotion';
import { EASE_IN_OUT, tween } from '../lib/motion';
import { color } from '../theme';

const HALF = 9;

/**
 * An indigo field with a coral leading edge that sweeps up over a scene cut:
 * it covers the frame by `at` and clears it HALF frames later.
 */
export function Wipe({ at }: { at: number }): React.JSX.Element | null {
  const frame = useCurrentFrame();
  if (frame < at - HALF || frame > at + HALF) return null;
  // 0 = below the frame, 1 = covering it, 2 = gone off the top.
  const p = tween(frame, [at - HALF, at, at + HALF], [0, 1, 2], EASE_IN_OUT);
  const y = (1 - p) * 2300;
  return (
    <AbsoluteFill style={{ pointerEvents: 'none', zIndex: 100 }}>
      <div
        style={{
          position: 'absolute',
          left: -200,
          right: -200,
          top: y - 100,
          height: 2300,
          background: color.ink,
          transform: 'rotate(-6deg)',
        }}
      >
        <div style={{ height: 40, background: color.coral }} />
      </div>
    </AbsoluteFill>
  );
}
