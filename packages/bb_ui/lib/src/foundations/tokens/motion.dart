import 'package:flutter/widgets.dart';

/// Durations and curves (DESIGN.md §7). Motion explains a change; it is
/// never decoration.
abstract final class AppMotion {
  /// Press states, toggles, chip select, icon swap.
  static const fast = Duration(milliseconds: 150);

  /// Cards, banners, page transitions, theme cross-fade, number tweens.
  static const normal = Duration(milliseconds: 250);

  /// Countdown ring arc, bottom sheet, chart reveal.
  static const slow = Duration(milliseconds: 400);

  /// One full skeleton opacity pulse.
  static const skeletonPulse = Duration(milliseconds: 1200);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve pulse = Curves.easeInOut;

  /// [duration], or zero when the user asked the OS to reduce motion.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
