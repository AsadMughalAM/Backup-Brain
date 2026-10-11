import 'spacing.dart';

/// Window size classes and their layout grid (DESIGN.md §4.2). Phone first;
/// the same breakpoints apply to the website.
enum WindowClass {
  compact(columns: 4, margin: AppSpacing.lg, gutter: AppSpacing.md),
  medium(
    columns: 8,
    margin: AppSpacing.xl,
    gutter: AppSpacing.lg,
    maxContentWidth: 720,
  ),
  expanded(
    columns: 12,
    margin: AppSpacing.xxl,
    gutter: AppSpacing.xl,
    maxContentWidth: 1080,
  );

  const WindowClass({
    required this.columns,
    required this.margin,
    required this.gutter,
    this.maxContentWidth,
  });

  final int columns;
  final double margin;
  final double gutter;

  /// Null means full width.
  final double? maxContentWidth;

  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 840;

  static WindowClass forWidth(double width) => width < mediumMinWidth
      ? compact
      : width <= expandedMinWidth
      ? medium
      : expanded;
}
