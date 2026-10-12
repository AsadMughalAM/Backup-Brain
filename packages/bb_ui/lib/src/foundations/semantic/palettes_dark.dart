import '../primitives/color_primitives.dart';
import 'app_colors.dart';
import 'energy_colors.dart';

/// Dark theme values (DESIGN.md §2.4–§2.5): deep indigo night for 2 AM
/// outages. Designed, not inverted: 300-tones for color, mist text, lighter
/// surfaces instead of shadows.
final darkAppColors = AppColors(
  background: MistP.c950,
  surface: MistP.c900,
  surfaceRaised: MistP.c850,
  surfaceMuted: MistP.c800,
  hero: IndigoP.c800,
  textPrimary: MistP.c100,
  textMuted: MistP.c400,
  textOnPrimary: IndigoP.c950,
  outline: MistP.c500,
  outlineVariant: MistP.c800,
  primary: CoralP.c400,
  primaryContainer: CoralP.night,
  onPrimaryContainer: CoralP.c200,
  secondary: IndigoP.c300,
  onSecondary: IndigoP.c950,
  secondaryContainer: IndigoP.c800,
  onSecondaryContainer: IndigoP.c100,
  link: IndigoP.c300,
  focusRing: CoralP.c400,
  success: StatusP.success300,
  successContainer: StatusP.success900,
  warning: StatusP.warning300,
  warningContainer: StatusP.warning900,
  danger: StatusP.danger300,
  dangerContainer: StatusP.danger900,
  onDanger: IndigoP.c950,
  info: IndigoP.c300,
  skeleton: MistP.c800,
  scrim: MistP.black.withValues(alpha: 0.6),
);

const darkEnergyColors = EnergyColors(
  solar: AmberP.c400,
  solarStroke: AmberP.c400,
  solarText: AmberP.c300,
  grid: IndigoP.c300,
  load: MistP.c300,
  batteryHigh: StatusP.success300,
  batteryMid: StatusP.warning300,
  batteryLow: StatusP.danger300,
  offline: MistP.c500,
);
