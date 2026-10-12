import type { CSSProperties, ReactNode } from 'react';
import { color, radius, shadow } from '../theme';

type Tone = 'standard' | 'highlight' | 'hero';

const TONES: Record<Tone, CSSProperties> = {
  standard: { background: color.surface, boxShadow: shadow.level1, borderRadius: radius.lg, padding: 16 },
  highlight: { background: color.coralContainer, color: color.onCoralContainer, borderRadius: radius.lg, padding: 16 },
  hero: { background: color.ink, color: color.nightText, borderRadius: radius.xl, padding: 24 },
};

/** BbCard: surface + shadow, never a border. */
export function Card({
  tone = 'standard',
  style,
  children,
}: {
  tone?: Tone;
  style?: CSSProperties;
  children: ReactNode;
}): React.JSX.Element {
  return <div style={{ ...TONES[tone], ...style }}>{children}</div>;
}
