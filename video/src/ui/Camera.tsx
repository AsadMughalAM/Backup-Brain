import type { ReactNode } from 'react';
import { AbsoluteFill, useCurrentFrame } from 'remotion';
import { tween } from '../lib/motion';
import { VIDEO } from '../theme';

/** Zoom `scale` around frame point (x, y), reached at frame `at`. */
export interface CameraKey {
  at: number;
  x: number;
  y: number;
  scale: number;
  /** Optional shake strength in px, for slams. */
  shake?: number;
}

export const WIDE: Omit<CameraKey, 'at'> = { x: VIDEO.width / 2, y: VIDEO.height / 2, scale: 1 };

/**
 * Slow pushes in on whatever the narration is talking about. Keeps the focus
 * point where it sits on screen, so a push never swings the frame sideways.
 */
export function Camera({ keys, children }: { keys: CameraKey[]; children: ReactNode }): React.JSX.Element {
  const frame = useCurrentFrame();
  const frames = keys.map((k) => k.at);
  const pick = (field: 'x' | 'y' | 'scale') =>
    keys.length === 1 ? keys[0][field] : tween(frame, frames, keys.map((k) => k[field]));
  const scale = pick('scale');
  const x = pick('x');
  const y = pick('y');
  const shakeKey = [...keys].reverse().find((k) => k.shake && frame >= k.at);
  const since = shakeKey ? frame - shakeKey.at : Infinity;
  const shake = since < 14 ? (shakeKey?.shake ?? 0) * (1 - since / 14) : 0;
  const dx = Math.sin(frame * 2.7) * shake;
  const dy = Math.cos(frame * 3.1) * shake;
  return (
    <AbsoluteFill
      style={{
        transformOrigin: `${x}px ${y}px`,
        transform: `translate(${dx}px, ${dy}px) scale(${scale})`,
      }}
    >
      {children}
    </AbsoluteFill>
  );
}
