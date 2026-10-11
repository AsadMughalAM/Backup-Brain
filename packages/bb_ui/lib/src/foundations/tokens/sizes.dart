/// Icon sizes and touch targets (DESIGN.md §6.3).
abstract final class AppSizes {
  /// Inline with small text, inside chips and badges.
  static const double iconXs = 16;

  /// List leading icons, inputs, buttons.
  static const double iconSm = 20;

  /// App bar actions, nav bar. The default.
  static const double iconMd = 24;

  /// Stat tile icons, prominent banners.
  static const double iconLg = 32;

  /// Empty and error states (Duotone).
  static const double iconXl = 48;

  /// Every tappable area is at least this, even when the glyph is smaller.
  static const double minTouchTarget = 48;
}
