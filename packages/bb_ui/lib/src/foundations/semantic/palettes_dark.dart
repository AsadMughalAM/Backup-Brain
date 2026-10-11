import '../primitives/color_primitives.dart';
import 'app_colors.dart';
import 'energy_colors.dart';

/// Dark theme values (DESIGN.md §2.4–§2.5). Designed, not inverted: 300-tones
/// for color, off-white text, lighter surfaces instead of shadows.
final darkAppColors = AppColors(
  background: CanvasP.c950,
  surface: CanvasP.c900,
  surfaceRaised: CanvasP.c850,
  surfaceMuted: CanvasP.c800,
  hero: NavyP.c900,
  textPrimary: CanvasP.c100,
  textMuted: CanvasP.c400,
  textOnPrimary: NavyP.c950,
  outline: CanvasP.c500,
  outlineVariant: CanvasP.c800,
  primary: YellowP.c400,
  primaryContainer: YellowP.c950,
  onPrimaryContainer: YellowP.c200,
  secondary: NavyP.c300,
  onSecondary: NavyP.c950,
  secondaryContainer: NavyP.c900,
  onSecondaryContainer: NavyP.c100,
  link: NavyP.c300,
  focusRing: YellowP.c400,
  success: StatusP.success300,
  successContainer: StatusP.success900,
  warning: StatusP.warning300,
  warningContainer: StatusP.warning900,
  danger: StatusP.danger300,
  dangerContainer: StatusP.danger900,
  onDanger: NavyP.c950,
  info: NavyP.c300,
  skeleton: CanvasP.c800,
  scrim: CanvasP.black.withValues(alpha: 0.6),
);

const darkEnergyColors = EnergyColors(
  solar: YellowP.c400,
  solarStroke: YellowP.c400,
  solarText: YellowP.c400,
  grid: NavyP.c400,
  load: CanvasP.c300,
  batteryHigh: StatusP.success300,
  batteryMid: StatusP.warning300,
  batteryLow: StatusP.danger300,
  offline: CanvasP.c500,
);
