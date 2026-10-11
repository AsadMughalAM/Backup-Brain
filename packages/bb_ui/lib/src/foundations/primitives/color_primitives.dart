// LAYER 1 — raw palette values from DESIGN.md §2.2–§2.3. Package-private:
// never exported, never used by widgets. Semantic tokens reference these.
import 'dart:ui';

abstract final class CanvasP {
  static const c0 = Color(0xFFFFFFFF),
      c50 = Color(0xFFF7F8FA),
      c100 = Color(0xFFEEF0F3),
      c200 = Color(0xFFE1E4E9),
      c300 = Color(0xFFC9CED6),
      c400 = Color(0xFF9AA2AF),
      c500 = Color(0xFF7D8592),
      c600 = Color(0xFF5A6270),
      c700 = Color(0xFF3E4550),
      c800 = Color(0xFF222733),
      c850 = Color(0xFF1A1E27),
      c900 = Color(0xFF13161D),
      c950 = Color(0xFF0B0D12);

  /// Only for the dark-theme scrim and shadows; never text or surfaces.
  static const black = Color(0xFF000000);
}

abstract final class NavyP {
  static const c50 = Color(0xFFF2F5FB),
      c100 = Color(0xFFE4EAF6),
      c200 = Color(0xFFC5D3EE),
      c300 = Color(0xFF9DB4E8),
      c400 = Color(0xFF7E9EE0),
      c500 = Color(0xFF4F72C2),
      c600 = Color(0xFF3A5FB0),
      c700 = Color(0xFF2A4A8E),
      c800 = Color(0xFF1F3A70),
      c900 = Color(0xFF152851),
      c950 = Color(0xFF0E1526);
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
