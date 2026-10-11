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
  // BbCountdownRing caption sits on the hero card.
  ('textMuted', 'secondaryContainer', _text),
];

const List<_Pair> _energyPairs = [
  ('solarText', 'surface', _text),
  ('solarStroke', 'surface', _ui),
  ('grid', 'surface', _ui),
  ('load', 'surface', _ui),
  ('offline', 'surface', _ui),
];

void main() {
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
