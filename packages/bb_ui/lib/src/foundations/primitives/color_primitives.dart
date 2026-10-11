// LAYER 1 — raw palette values from DESIGN.md §2.2–§2.3. Package-private:
// never exported, never used by widgets. Semantic tokens reference these.
import 'dart:ui';

/// Warm stone neutrals (hue ≈ 40°). Warm, not cool, so they sit in harmony
/// with Spark Yellow instead of fighting it.
abstract final class CanvasP {
  static const c0 = Color(0xFFFFFFFF),
      c50 = Color(0xFFF6F4F0),
      c100 = Color(0xFFEDEAE4),
      c200 = Color(0xFFE2DED6),
      c300 = Color(0xFFCBC6BC),
      c400 = Color(0xFFA39D92),
      c500 = Color(0xFF857F74),
      c600 = Color(0xFF5E594F),
      c700 = Color(0xFF423E37),
      c800 = Color(0xFF2A2824),
      c850 = Color(0xFF211F1C),
      c900 = Color(0xFF1A1917),
      c950 = Color(0xFF121110);

  /// Only for the dark-theme scrim and shadows; never text or surfaces.
  static const black = Color(0xFF000000);
}

/// Midnight navy: deep and low-chroma so it reads as night sky, not as a
/// pastel UI tint.
abstract final class NavyP {
  static const c50 = Color(0xFFF1F3F8),
      c100 = Color(0xFFE3E7F0),
      c200 = Color(0xFFC6CEDF),
      c300 = Color(0xFFA3B2D1),
      c400 = Color(0xFF7C90BE),
      c500 = Color(0xFF5670A6),
      c600 = Color(0xFF3F5891),
      c700 = Color(0xFF2E4378),
      c800 = Color(0xFF1F2F57),
      c900 = Color(0xFF16213D),
      c950 = Color(0xFF0E1424);
}

abstract final class YellowP {
  static const c50 = Color(0xFFFFFBEB),
      c100 = Color(0xFFFFF3CC),
      c200 = Color(0xFFFFE7A3),
      c300 = Color(0xFFFFD666),
      c400 = Color(0xFFFFC93D),
      c500 = Color(0xFFFFC21A),
      c600 = Color(0xFFE6A800),
      c700 = Color(0xFFB38300),
      c800 = Color(0xFF8A6200),
      c900 = Color(0xFF4D3800),
      c950 = Color(0xFF2E2100);
}

abstract final class StatusP {
  static const success100 = Color(0xFFDDF3E4),
      success300 = Color(0xFF5CCB82),
      success600 = Color(0xFF1E7A3D),
      success900 = Color(0xFF0E3A1E);
  static const warning100 = Color(0xFFFFE6D2),
      warning300 = Color(0xFFFF9F5A),
      warning600 = Color(0xFFA34706),
      warning900 = Color(0xFF4A2004);
  static const danger100 = Color(0xFFFDE1DF),
      danger300 = Color(0xFFFF7A70),
      danger600 = Color(0xFFC42B22),
      danger900 = Color(0xFF4F1210);
}
