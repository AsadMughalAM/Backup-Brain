import type { ReactNode } from 'react';
import { color, radius, type } from '../theme';

/** BbSwitch: 52×32 track, indigo when on. `on` is 0→1 so it can slide. */
export function Switch({ on }: { on: number }): React.JSX.Element {
  return (
    <div
      style={{
        width: 52,
        height: 32,
        borderRadius: radius.pill,
        background: on > 0.5 ? color.ink : color.divider,
        position: 'relative',
        flexShrink: 0,
      }}
    >
      <div
        style={{
          position: 'absolute',
          top: 4,
          left: 4 + on * 20,
          width: 24,
          height: 24,
          borderRadius: '50%',
          background: on > 0.5 ? '#fff' : color.outline,
        }}
      />
    </div>
  );
}

/** BbChip: pill, indigo when selected. */
export function Chip({ selected, children }: { selected: boolean; children: ReactNode }): React.JSX.Element {
  return (
    <div
      style={{
        height: 36,
        padding: '0 16px',
        display: 'inline-flex',
        alignItems: 'center',
        gap: 6,
        borderRadius: radius.pill,
        background: selected ? color.ink : color.surface,
        color: selected ? '#fff' : color.ink,
        ...type.labelLarge,
      }}
    >
      {children}
    </div>
  );
}

/** BbButton: pill. Secondary is indigo, ghost is muted text on mist. */
export function Button({
  variant,
  press = 0,
  children,
  full,
}: {
  variant: 'secondary' | 'ghost' | 'tonal';
  press?: number;
  children: ReactNode;
  full?: boolean;
}): React.JSX.Element {
  const look = {
    secondary: { background: color.ink, color: '#fff', height: 52, padding: '0 24px' },
    tonal: { background: color.indigoContainer, color: color.ink, height: 40, padding: '0 16px' },
    ghost: { background: color.surfaceMuted, color: color.ink, height: 36, padding: '0 14px' },
  }[variant];
  return (
    <div
      style={{
        ...look,
        ...type.labelLarge,
        width: full ? '100%' : undefined,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        borderRadius: radius.pill,
        transform: `scale(${1 - press * 0.05})`,
        flexShrink: 0,
      }}
    >
      {children}
    </div>
  );
}

/** A round tinted disc behind an icon, as in BbStatTile and list rows. */
export function IconDisc({
  bg,
  fg,
  size = 40,
  children,
}: {
  bg: string;
  fg: string;
  size?: number;
  children: ReactNode;
}): React.JSX.Element {
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: '50%',
        background: bg,
        color: fg,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        flexShrink: 0,
      }}
    >
      {children}
    </div>
  );
}
