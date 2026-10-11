/// State-layer opacities, matching Material's (DESIGN.md §2.7 rule 7).
/// States use opacity over existing colors, never new colors.
abstract final class AppOpacity {
  static const double disabled = 0.38;
  static const double pressed = 0.12;
  static const double hover = 0.08;
}
