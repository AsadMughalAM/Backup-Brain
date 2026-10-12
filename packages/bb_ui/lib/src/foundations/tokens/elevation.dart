import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

import '../primitives/color_primitives.dart';

enum AppElevation {
  /// Flat page content and inner `surfaceMuted` groups.
  level0,

  /// Cards, list groups, nav bar, sticky CTA bar.
  level1,

  /// Menus, dropdowns, toasts.
  level2,

  /// Bottom sheets, dialogs.
  level3;

  /// Soft indigo-tinted shadows in light mode (DESIGN.md §5.3). Dark mode has
  /// none: elevation there comes from a lighter surface color instead.
  List<BoxShadow> shadows(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return switch (this) {
      level0 => const [],
      // A tight contact shadow plus a wide ambient one reads as soft depth
      // rather than a drop shadow.
      level1 => [_shadow(0.05, 1, 2), _shadow(0.07, 10, 30)],
      level2 => [_shadow(0.06, 2, 4), _shadow(0.10, 14, 36)],
      level3 => [_shadow(0.08, 4, 8), _shadow(0.16, 24, 56)],
    };
  }

  static BoxShadow _shadow(double alpha, double y, double blur) => BoxShadow(
    color: IndigoP.c950.withValues(alpha: alpha),
    offset: Offset(0, y),
    blurRadius: blur,
  );
}
