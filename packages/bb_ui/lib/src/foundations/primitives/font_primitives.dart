// LAYER 1 — font families and weights (DESIGN.md §3). Package-private.
import 'dart:ui';

abstract final class FontP {
  /// Fonts are declared in bb_ui's pubspec, so styles must name the package.
  static const package = 'bb_ui';
  static const sans = 'Manrope';

  static const regular = FontWeight.w400,
      medium = FontWeight.w500,
      semibold = FontWeight.w600,
      bold = FontWeight.w700,
      extrabold = FontWeight.w800;
}
