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

  /// Soft navy-tinted shadows in light mode (DESIGN.md §5.3). Dark mode has
  /// none: elevation there comes from a lighter surface color instead.
  List<BoxShadow> shadows(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return switch (this) {
      level0 => const [],
      level1 => [_shadow(0.08, 1, 3)],
      level2 => [_shadow(0.08, 4, 12)],
      level3 => [_shadow(0.12, 12, 32)],
    };
  }

  static BoxShadow _shadow(double alpha, double y, double blur) => BoxShadow(
    color: NavyP.c950.withValues(alpha: alpha),
    offset: Offset(0, y),
    blurRadius: blur,
  );
}
