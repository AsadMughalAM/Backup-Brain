/**
 * Backup Brain's "Quiet Home" tokens (DESIGN.md §2–§6, packages/bb_ui
 * foundations), copied once here so every screen in the video uses them.
 */
export const VIDEO = { width: 1080, height: 1920, fps: 30 } as const;

export const color = {
  bg: '#EEF1F6',
  surface: '#FFFFFF',
  surfaceMuted: '#EEF1F6',
  ink: '#1B1F3B',
  inkDeep: '#12152A',
  muted: '#555D80',
  coral: '#FF6B4A',
  coralContainer: '#FFE4DD',
  onCoralContainer: '#4D190D',
  indigoContainer: '#E3E6F7',
  info: '#414BA4',
  outline: '#7C84A3',
  divider: '#E3E7F0',
  success: '#137A54',
  successContainer: '#DDF4EA',
  warning: '#9E4A00',
  warningContainer: '#FFEBD3',
  danger: '#C4283C',
  dangerContainer: '#FDE2E5',
  solar: '#F5A623',
  solarStroke: '#A86A00',
  solarText: '#7F5000',
  // Dark palette: problem scenes and the content of the indigo hero card.
  night: '#0E1024',
  nightSurface: '#181B33',
  nightText: '#EEF1F6',
  nightMuted: '#A3AAC2',
} as const;

export const radius = { sm: 8, md: 14, lg: 24, xl: 32, pill: 999 } as const;

const tint = (a: number) => `rgba(18,21,42,${a})`;
export const shadow = {
  level1: `0 1px 2px ${tint(0.05)}, 0 10px 30px ${tint(0.07)}`,
  level2: `0 2px 4px ${tint(0.06)}, 0 14px 36px ${tint(0.1)}`,
  level3: `0 4px 8px ${tint(0.08)}, 0 24px 56px ${tint(0.16)}`,
  /** Ad-only: a card lifted out of the phone toward the camera. */
  float: `0 10px 20px ${tint(0.12)}, 0 40px 90px ${tint(0.28)}`,
} as const;

export const font = {
  sans: 'Manrope, sans-serif',
  /** Numbers always use tabular figures, as in the app. */
  tabular: { fontVariantNumeric: 'tabular-nums' } as const,
};

/** DESIGN.md type scale, size / line height / weight / tracking. */
export const type = {
  metricHero: { fontSize: 56, lineHeight: '60px', fontWeight: 800, letterSpacing: -2.4 },
  metricLarge: { fontSize: 32, lineHeight: '38px', fontWeight: 800, letterSpacing: -1.2 },
  metricMedium: { fontSize: 20, lineHeight: '24px', fontWeight: 700, letterSpacing: -0.4 },
  metricSmall: { fontSize: 16, lineHeight: '20px', fontWeight: 600, letterSpacing: -0.1 },
  headlineSmall: { fontSize: 24, lineHeight: '32px', fontWeight: 700, letterSpacing: -0.5 },
  titleLarge: { fontSize: 20, lineHeight: '28px', fontWeight: 700, letterSpacing: -0.3 },
  titleMedium: { fontSize: 16, lineHeight: '24px', fontWeight: 700 },
  titleSmall: { fontSize: 14, lineHeight: '20px', fontWeight: 700 },
  bodyLarge: { fontSize: 16, lineHeight: '24px', fontWeight: 500 },
  bodyMedium: { fontSize: 14, lineHeight: '20px', fontWeight: 500 },
  bodySmall: { fontSize: 12, lineHeight: '16px', fontWeight: 500 },
  labelLarge: { fontSize: 14, lineHeight: '20px', fontWeight: 600 },
  labelMedium: { fontSize: 12, lineHeight: '16px', fontWeight: 600 },
} as const;
