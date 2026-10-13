import { tween } from './motion';

/** 0 → 1 → 0 around `at`: a short emphasis bump when a number lands. */
export function pulse(frame: number, at: number): number {
  return tween(frame, [at, at + 6, at + 22], [0, 1, 0]);
}
