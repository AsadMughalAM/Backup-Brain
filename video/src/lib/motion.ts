import { Easing, interpolate, spring } from 'remotion';

/** The portal's own motion curve (framer `[0.16, 1, 0.3, 1]`). */
export const EASE_OUT = Easing.bezier(0.16, 1, 0.3, 1);
export const EASE_IN_OUT = Easing.bezier(0.65, 0, 0.35, 1);

const CLAMP = { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' } as const;

/** 0 → 1 between two frames on the house curve. */
export function progress(frame: number, start: number, duration: number, easing = EASE_OUT): number {
  return interpolate(frame, [start, start + duration], [0, 1], { ...CLAMP, easing });
}

/** Multi-stop interpolation, clamped, smooth in and out. */
export function tween(frame: number, input: number[], output: number[], easing = EASE_IN_OUT): number {
  return interpolate(frame, input, output, { ...CLAMP, easing });
}

/** A soft, slightly springy entrance for things that pop in: dialogs, toasts, badges. */
export function pop(frame: number, start: number, fps: number): number {
  return spring({ frame: frame - start, fps, config: { damping: 18, stiffness: 170, mass: 0.8 } });
}

/** Fade and rise, as a style. */
export function enter(frame: number, start: number, duration = 14, rise = 14): React.CSSProperties {
  const p = progress(frame, start, duration);
  return { opacity: p, transform: `translateY(${(1 - p) * rise}px)` };
}

/** How much of a string has been typed by this frame. */
export function typed(value: string, frame: number, start: number, charsPerFrame = 1.1): string {
  return value.slice(0, Math.max(0, Math.floor((frame - start) * charsPerFrame)));
}
