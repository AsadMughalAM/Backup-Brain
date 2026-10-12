import 'package:flutter/material.dart';

import '../primitives/font_primitives.dart';

/// LAYER 2 — the type scale (DESIGN.md §3.4). Material roles go into
/// [textTheme]; the metric styles for live numbers live on this extension. Read via `context.text` / `context.textTheme`.
///
/// Styles carry no color: Text inherits `textPrimary` from the theme, and
/// muted text picks `textMuted` explicitly.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.metricHero,
    required this.metricLarge,
    required this.metricMedium,
    required this.metricSmall,
    required this.metricCaption,
  });

  static final standard = AppTypography(
    metricHero: _metric(56, 60, FontP.extrabold, -2.4),
    metricLarge: _metric(32, 38, FontP.extrabold, -1.2),
    metricMedium: _metric(20, 24, FontP.bold, -0.4),
    metricSmall: _metric(16, 20, FontP.semibold, -0.1),
    metricCaption: _metric(12, 16, FontP.semibold, 0),
  );

  /// Backup countdown "3h 20m". May clamp at 1.3× text scale; nothing else
  /// clamps (DESIGN.md §3.5).
  final TextStyle metricHero;

  /// Stat tiles (kWh, %, PKR).
  final TextStyle metricLarge;

  /// Package prices, secondary stats.
  final TextStyle metricMedium;

  /// Inline numbers in lists ("+2h 10m", "750 W").
  final TextStyle metricSmall;

  /// Chart axes, timestamps, "updated 3 h ago".
  final TextStyle metricCaption;

  static final TextTheme textTheme = TextTheme(
    displaySmall: _sans(32, 40, FontP.extrabold, -1.0),
    headlineMedium: _sans(28, 36, FontP.extrabold, -0.8),
    headlineSmall: _sans(24, 32, FontP.bold, -0.5),
    titleLarge: _sans(20, 28, FontP.bold, -0.3),
    titleMedium: _sans(16, 24, FontP.bold, -0.1),
    titleSmall: _sans(14, 20, FontP.bold, 0),
    bodyLarge: _sans(16, 24, FontP.medium, 0),
    bodyMedium: _sans(14, 20, FontP.medium, 0),
    bodySmall: _sans(12, 16, FontP.medium, 0.1),
    labelLarge: _sans(14, 20, FontP.semibold, 0.1),
    labelMedium: _sans(12, 16, FontP.semibold, 0.2),
    labelSmall: _sans(11, 16, FontP.semibold, 0.4),
  );

  static TextStyle _sans(double size, double line, FontWeight w, double ls) =>
      TextStyle(
        fontFamily: FontP.sans,
        package: FontP.package,
        fontSize: size,
        height: line / size,
        fontWeight: w,
        letterSpacing: ls,
      );

  // Manrope, not a monospace: tabular figures already keep every digit the
  // same width (no jitter while the countdown ticks, columns line up),
  // without making numbers look like code.
  static TextStyle _metric(double size, double line, FontWeight w, double ls) =>
      TextStyle(
        fontFamily: FontP.sans,
        package: FontP.package,
        fontSize: size,
        height: line / size,
        fontWeight: w,
        letterSpacing: ls,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  @override
  AppTypography copyWith({
    TextStyle? metricHero,
    TextStyle? metricLarge,
    TextStyle? metricMedium,
    TextStyle? metricSmall,
    TextStyle? metricCaption,
  }) => AppTypography(
    metricHero: metricHero ?? this.metricHero,
    metricLarge: metricLarge ?? this.metricLarge,
    metricMedium: metricMedium ?? this.metricMedium,
    metricSmall: metricSmall ?? this.metricSmall,
    metricCaption: metricCaption ?? this.metricCaption,
  );

  @override
  AppTypography lerp(AppTypography? other, double t) {
    if (other == null) return this;
    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      metricHero: s(metricHero, other.metricHero),
      metricLarge: s(metricLarge, other.metricLarge),
      metricMedium: s(metricMedium, other.metricMedium),
      metricSmall: s(metricSmall, other.metricSmall),
      metricCaption: s(metricCaption, other.metricCaption),
    );
  }
}
