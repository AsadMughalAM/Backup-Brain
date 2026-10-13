import type { CSSProperties } from 'react';
import { EASE_OUT } from '../lib/motion';

/**
 * BbAppear for props-only screens: `reveal` runs 0→1 across the whole screen,
 * and section `index` of `count` fades and rises 16px in its own slice.
 */
export function appear(reveal: number, index: number, count: number): CSSProperties {
  const slice = Math.max(0, Math.min(1, reveal * (count + 1) - index));
  const p = EASE_OUT(slice);
  return { opacity: p, transform: `translateY(${(1 - p) * 16}px)` };
}
