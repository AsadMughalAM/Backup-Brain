import '../primitives/color_primitives.dart';
import 'app_colors.dart';
import 'energy_colors.dart';

/// Light theme values (DESIGN.md §2.4–§2.5). High contrast for strong sun.
final lightAppColors = AppColors(
  background: CanvasP.c50,
  surface: CanvasP.c0,
  surfaceRaised: CanvasP.c0,
  surfaceMuted: CanvasP.c100,
  textPrimary: NavyP.c950,
  textMuted: CanvasP.c600,
  textOnPrimary: NavyP.c950,
  outline: CanvasP.c500,
  outlineVariant: CanvasP.c200,
  primary: YellowP.c500,
  primaryContainer: YellowP.c100,
  onPrimaryContainer: YellowP.c900,
  secondary: NavyP.c800,
  onSecondary: CanvasP.c0,
  secondaryContainer: NavyP.c100,
  onSecondaryContainer: NavyP.c900,
  link: NavyP.c700,
  focusRing: NavyP.c600,
  success: StatusP.success600,
  successContainer: StatusP.success100,
  warning: StatusP.warning600,
  warningContainer: StatusP.warning100,
  danger: StatusP.danger600,
  dangerContainer: StatusP.danger100,
  onDanger: CanvasP.c0,
  info: NavyP.c600,
  skeleton: CanvasP.c100,
  scrim: NavyP.c950.withValues(alpha: 0.4),
);

const lightEnergyColors = EnergyColors(
  solar: YellowP.c500,
  solarStroke: YellowP.c700,
  solarText: YellowP.c800,
  grid: NavyP.c600,
  load: CanvasP.c700,
  batteryHigh: StatusP.success600,
  batteryMid: StatusP.warning600,
  batteryLow: StatusP.danger600,
  offline: CanvasP.c500,
);
