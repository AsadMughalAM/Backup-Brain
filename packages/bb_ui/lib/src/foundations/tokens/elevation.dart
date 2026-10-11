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

  /// Soft warm-ink shadows in light mode (DESIGN.md §5.3). Dark mode has
  /// none: elevation there comes from a lighter surface color instead.
  List<BoxShadow> shadows(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return switch (this) {
      level0 => const [],
      // A tight contact shadow plus a wide ambient one reads as soft depth
      // rather than a drop shadow.
      level1 => [_shadow(0.04, 1, 2), _shadow(0.06, 8, 24)],
      level2 => [_shadow(0.05, 2, 4), _shadow(0.08, 12, 32)],
      level3 => [_shadow(0.06, 4, 8), _shadow(0.14, 24, 56)],
    };
  }

  static BoxShadow _shadow(double alpha, double y, double blur) => BoxShadow(
    color: CanvasP.c950.withValues(alpha: alpha),
    offset: Offset(0, y),
    blurRadius: blur,
  );
}
