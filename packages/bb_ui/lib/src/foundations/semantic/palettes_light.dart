import '../primitives/color_primitives.dart';
import 'app_colors.dart';
import 'energy_colors.dart';

/// Light theme values (DESIGN.md §2.4–§2.5): white cards on cool mist,
/// indigo ink, one coral accent. High contrast for strong sun.
final lightAppColors = AppColors(
  background: MistP.c100,
  surface: MistP.c0,
  surfaceRaised: MistP.c0,
  surfaceMuted: MistP.c100,
  hero: IndigoP.c900,
  textPrimary: IndigoP.c900,
  textMuted: MistP.c600,
  textOnPrimary: IndigoP.c950,
  outline: MistP.c500,
  outlineVariant: MistP.c200,
  primary: CoralP.c500,
  primaryContainer: CoralP.c100,
  onPrimaryContainer: CoralP.c900,
  secondary: IndigoP.c900,
  onSecondary: MistP.c0,
  secondaryContainer: IndigoP.c100,
  onSecondaryContainer: IndigoP.c900,
  link: IndigoP.c600,
  focusRing: IndigoP.c600,
  success: StatusP.success600,
  successContainer: StatusP.success100,
  warning: StatusP.warning600,
  warningContainer: StatusP.warning100,
  danger: StatusP.danger600,
  dangerContainer: StatusP.danger100,
  onDanger: MistP.c0,
  info: IndigoP.c600,
  skeleton: MistP.c200,
  scrim: IndigoP.c950.withValues(alpha: 0.4),
);

const lightEnergyColors = EnergyColors(
  solar: AmberP.c500,
  solarStroke: AmberP.c700,
  solarText: AmberP.c800,
  grid: IndigoP.c600,
  load: MistP.c700,
  batteryHigh: StatusP.success600,
  batteryMid: StatusP.warning600,
  batteryLow: StatusP.danger600,
  offline: MistP.c500,
);
