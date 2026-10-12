// LAYER 1 — raw palette values from DESIGN.md §2.2–§2.3. Package-private:
// never exported, never used by widgets. Semantic tokens reference these.
import 'dart:ui';

/// Cool mist neutrals (hue ≈ 225°): calm surfaces that let the indigo ink
/// and the one coral accent carry the meaning.
abstract final class MistP {
  static const c0 = Color(0xFFFFFFFF),
      c50 = Color(0xFFF6F7FB),
      c100 = Color(0xFFEEF1F6),
      c200 = Color(0xFFE3E7F0),
      c300 = Color(0xFFCDD3E1),
      c400 = Color(0xFFA3AAC2),
      c500 = Color(0xFF7C84A3),
      c600 = Color(0xFF555D80),
      c700 = Color(0xFF3F4668),
      c800 = Color(0xFF282D4C),
      c850 = Color(0xFF1F2340),
      c900 = Color(0xFF181B33),
      c950 = Color(0xFF0E1024);

  /// Only for the dark-theme scrim; never text or surfaces.
  static const black = Color(0xFF000000);
}

/// Indigo ink: text, structure, selected states and the night hero card.
abstract final class IndigoP {
  static const c50 = Color(0xFFF0F1FA),
      c100 = Color(0xFFE3E6F7),
      c200 = Color(0xFFC7CCEE),
      c300 = Color(0xFFA6AEE6),
      c400 = Color(0xFF7F89D6),
      c500 = Color(0xFF5965C2),
      c600 = Color(0xFF414BA4),
      c700 = Color(0xFF313884),
      c800 = Color(0xFF262B66),
      c900 = Color(0xFF1B1F3B),
      c950 = Color(0xFF12152A);
}

/// Coral: the one accent — the screen's main action and active marks.
abstract final class CoralP {
  static const c50 = Color(0xFFFFF4F1),
      c100 = Color(0xFFFFE4DD),
      c200 = Color(0xFFFFC7B9),
      c300 = Color(0xFFFF9F88),
      c400 = Color(0xFFFF876B),
      c500 = Color(0xFFFF6B4A),
      c600 = Color(0xFFE5502F),
      c700 = Color(0xFFB83C20),
      c800 = Color(0xFF8A2D18),
      c900 = Color(0xFF4D190D),
      c950 = Color(0xFF2E1008);

  /// Coral glow on the indigo night: dark-theme highlight cards.
  static const night = Color(0xFF34213A);
}

/// Sun amber: solar energy only, never actions.
abstract final class AmberP {
  static const c100 = Color(0xFFFFF1D6),
      c300 = Color(0xFFFFCF73),
      c400 = Color(0xFFFFC04D),
      c500 = Color(0xFFF5A623),
      c700 = Color(0xFFA86A00),
      c800 = Color(0xFF7F5000);
}

abstract final class StatusP {
  static const success100 = Color(0xFFDDF4EA),
      success300 = Color(0xFF52D29D),
      success600 = Color(0xFF137A54),
      success900 = Color(0xFF0B3A28);
  static const warning100 = Color(0xFFFFEBD3),
      warning300 = Color(0xFFFFB25C),
      warning600 = Color(0xFF9E4A00),
      warning900 = Color(0xFF4A2600);
  static const danger100 = Color(0xFFFDE2E5),
      danger300 = Color(0xFFFF7D8C),
      danger600 = Color(0xFFC4283C),
      danger900 = Color(0xFF4F0F18);
}
