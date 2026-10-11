import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final light = AppTheme.light();
  final dark = AppTheme.dark();

  test('both themes register all three extensions', () {
    for (final t in [light, dark]) {
      expect(t.extension<AppColors>(), isNotNull);
      expect(t.extension<EnergyColors>(), isNotNull);
      expect(t.extension<AppTypography>(), isNotNull);
      expect(t.useMaterial3, isTrue);
    }
  });

  test('light and dark define the same color tokens', () {
    expect(
      dark.extension<AppColors>()!.tokens.keys,
      light.extension<AppColors>()!.tokens.keys,
    );
    expect(
      dark.extension<EnergyColors>()!.tokens.keys,
      light.extension<EnergyColors>()!.tokens.keys,
    );
  });

  test('dark is designed, not a copy: surfaces and text differ', () {
    final l = light.extension<AppColors>()!, d = dark.extension<AppColors>()!;
    expect(d.background, isNot(l.background));
    expect(d.textPrimary, isNot(l.textPrimary));
    expect(d.secondary, isNot(l.secondary));
  });

  test('no pure white text in dark mode (DESIGN.md §2.7 rule 6)', () {
    final d = dark.extension<AppColors>()!;
    expect(d.textPrimary, isNot(const Color(0xFFFFFFFF)));
  });

  test('lerp at 0 and 1 returns the end themes', () {
    final l = light.extension<AppColors>()!, d = dark.extension<AppColors>()!;
    expect(l.lerp(d, 0).tokens, l.tokens);
    expect(l.lerp(d, 1).tokens, d.tokens);
  });

  test('ColorScheme is not seed-generated: primary is Spark Yellow', () {
    expect(light.colorScheme.primary, light.extension<AppColors>()!.primary);
    expect(dark.colorScheme.primary, dark.extension<AppColors>()!.primary);
    expect(light.colorScheme.surfaceTint, Colors.transparent);
  });

  test('metric styles use tabular figures', () {
    final t = light.extension<AppTypography>()!;
    for (final s in [
      t.metricHero,
      t.metricLarge,
      t.metricMedium,
      t.metricSmall,
      t.metricCaption,
    ]) {
      expect(s.fontFeatures, contains(const FontFeature.tabularFigures()));
    }
  });

  test('battery color follows the 50% / 20% thresholds', () {
    final e = light.extension<EnergyColors>()!;
    expect(e.battery(0.62), e.batteryHigh);
    expect(e.battery(0.5), e.batteryMid);
    expect(e.battery(0.2), e.batteryMid);
    expect(e.battery(0.12), e.batteryLow);
  });

  test('window classes match DESIGN.md §4.2', () {
    expect(WindowClass.forWidth(390), WindowClass.compact);
    expect(WindowClass.forWidth(600), WindowClass.medium);
    expect(WindowClass.forWidth(840), WindowClass.medium);
    expect(WindowClass.forWidth(1024), WindowClass.expanded);
  });
}
