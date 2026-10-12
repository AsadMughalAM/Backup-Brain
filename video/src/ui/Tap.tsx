import { useCurrentFrame } from 'remotion';
import { progress, tween } from '../lib/motion';

/**
 * A fingertip tap at a dp point inside the phone screen: the dot fades in,
 * presses at `at`, and leaves a ripple. Render it inside the Phone.
 */
export function Tap({ at, x, y }: { at: number; x: number; y: number }): React.JSX.Element | null {
  const frame = useCurrentFrame();
  if (frame < at - 10 || frame > at + 22) return null;
  const dot = tween(frame, [at - 10, at - 3, at + 6, at + 14], [0, 1, 1, 0]);
  const press = tween(frame, [at - 3, at, at + 5], [1, 0.8, 1]);
  const ripple = progress(frame, at, 18);
  return (
    <div style={{ position: 'absolute', left: x, top: y, zIndex: 40, pointerEvents: 'none' }}>
      <div
        style={{
          position: 'absolute',
          left: -26,
          top: -26,
          width: 52,
          height: 52,
          borderRadius: '50%',
          border: '2px solid rgba(27,31,59,0.45)',
          transform: `scale(${0.4 + ripple * 1.2})`,
          opacity: frame >= at ? 1 - ripple : 0,
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: -17,
          top: -17,
          width: 34,
          height: 34,
          borderRadius: '50%',
          background: 'rgba(27,31,59,0.28)',
          boxShadow: '0 0 0 2px rgba(255,255,255,0.7)',
          opacity: dot,
          transform: `scale(${press})`,
        }}
      />
    </div>
  );
}
