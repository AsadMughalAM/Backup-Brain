import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every text/background pair from DESIGN.md §2.8, checked in both themes.
/// Adding a token means adding its pair here (TECH_STACK.md §6.1).
typedef _Pair = (String fg, String bg, double min);

const _text = 4.5;
const _ui = 3.0;

const List<_Pair> _appColorPairs = [
  ('textPrimary', 'surface', _text),
  ('textPrimary', 'background', _text),
  ('textPrimary', 'surfaceMuted', _text),
  ('textMuted', 'surface', _text),
  ('textMuted', 'surfaceMuted', _text),
  ('textOnPrimary', 'primary', _text),
  ('onSecondary', 'secondary', _text),
  ('onSecondaryContainer', 'secondaryContainer', _text),
  ('onPrimaryContainer', 'primaryContainer', _text),
  ('onDanger', 'danger', _text),
  ('link', 'surface', _text),
  ('outline', 'surface', _ui),
  ('outline', 'background', _ui),
  ('success', 'surface', _text),
  ('success', 'successContainer', _text),
  ('warning', 'surface', _text),
  ('warning', 'warningContainer', _text),
  ('danger', 'surface', _text),
  ('danger', 'dangerContainer', _text),
  // BbBanner: body text and status icon on each container.
  ('textPrimary', 'secondaryContainer', _text),
  ('textPrimary', 'successContainer', _text),
  ('textPrimary', 'warningContainer', _text),
  ('textPrimary', 'dangerContainer', _text),
  ('info', 'secondaryContainer', _ui),
  // Body text on the highlight (AI advice) card.
  ('textPrimary', 'primaryContainer', _text),
];

/// The hero card draws its content with the dark palette in both themes
/// (BbCard hero variant), so dark tokens are checked against each `hero`.
const List<_Pair> _heroPairs = [
  ('textPrimary', 'hero', _text),
  ('textMuted', 'hero', _text),
  ('primary', 'hero', _ui),
  ('warning', 'hero', _ui),
  ('danger', 'hero', _ui),
  ('focusRing', 'hero', _ui),
];

const List<_Pair> _energyPairs = [
  ('solarText', 'surface', _text),
  ('solarStroke', 'surface', _ui),
  ('grid', 'surface', _ui),
  ('load', 'surface', _ui),
  ('offline', 'surface', _ui),
];

void main() {
  final darkColors = AppTheme.dark().extension<AppColors>()!.tokens;

  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    final colors = theme.extension<AppColors>()!.tokens;
    final energy = theme.extension<EnergyColors>()!.tokens;

    group('$name theme', () {
      for (final (fg, bg, min) in _appColorPairs) {
        test('$fg on $bg ≥ $min:1', () {
          expect(
            contrastRatio(colors[fg]!, colors[bg]!),
            greaterThanOrEqualTo(min),
          );
        });
      }
      for (final (fg, bg, min) in _heroPairs) {
        test('hero: dark $fg on $bg ≥ $min:1', () {
          expect(
            contrastRatio(darkColors[fg]!, colors[bg]!),
            greaterThanOrEqualTo(min),
          );
        });
      }
      for (final (fg, bg, min) in _energyPairs) {
        test('energy.$fg on $bg ≥ $min:1', () {
          expect(
            contrastRatio(energy[fg]!, colors[bg]!),
            greaterThanOrEqualTo(min),
          );
        });
      }
    });
  }

  test(
    'known exception: light solar fill is low contrast (needs a stroke)',
    () {
      final c = AppTheme.light().extension<AppColors>()!;
      final e = AppTheme.light().extension<EnergyColors>()!;
      expect(contrastRatio(e.solar, c.surface), lessThan(_ui));
    },
  );

  test('contrastRatio matches known WCAG values', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)),
      closeTo(4.48, 0.01),
    );
  });
}
