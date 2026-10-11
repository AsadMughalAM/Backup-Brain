import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';

/// One hour in a [BbSolarForecastStrip].
class BbSolarBar {
  const BbSolarBar({required this.value, this.potential, this.label});

  /// Expected generation, any unit (bars are scaled to the largest value).
  final double value;

  /// What a clear day would give, drawn as a faint bar behind [value].
  final double? potential;

  /// Hour label under the bar, e.g. "9". Null leaves the slot empty.
  final String? label;
}

/// Hourly solar bars, sunrise → sunset (DESIGN.md §10.6). Bars are the
/// solar fill with a `solarStroke` top edge (the fill alone is too faint on
/// light). A faint "clear day" bar behind each one shows how much the
/// clouds take away; the legend names both, so nothing relies on color.
///
/// ```dart
/// BbSolarForecastStrip(
///   bars: [for (final h in hours) BbSolarBar(value: h.wh, potential: h.clearWh, label: h.label)],
///   forecastLabel: l10n.forecast,
///   potentialLabel: l10n.clearDay,
///   semanticLabel: l10n.solarChartSemantics('3.8 kWh'),
/// )
/// ```
class BbSolarForecastStrip extends StatelessWidget {
  const BbSolarForecastStrip({
    super.key,
    required this.bars,
    required this.semanticLabel,
    required this.forecastLabel,
    this.potentialLabel,
  });

  final List<BbSolarBar> bars;

  /// The chart in one sentence for screen readers.
  final String semanticLabel;
  final String forecastLabel;

  /// Legend entry for the faint bars; shown when any bar has a potential.
  final String? potentialLabel;

  static const _chartHeight = 112.0;
  static const _edge = 2.0;
  static const _swatch = 10.0;

  // Opacity of the text color, so it suits both themes (DESIGN.md §2.7
  // rule 7).
  static const _ghostAlpha = 0.08;

  @override
  Widget build(BuildContext context) {
    final energy = context.energy;
    final ghost = context.colors.textPrimary.withValues(alpha: _ghostAlpha);
    final peak = bars.fold(
      0.0,
      (m, b) => math.max(m, math.max(b.value, b.potential ?? 0)),
    );
    double share(double v) => peak <= 0 ? 0 : (v / peak).clamp(0.0, 1.0);
    final potentialLabel = this.potentialLabel;
    final showPotential =
        potentialLabel != null && bars.any((b) => b.potential != null);

    final solarBar = BoxDecoration(
      color: energy.solar,
      border: Border(
        top: BorderSide(color: energy.solarStroke, width: _edge),
      ),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xs),
      ),
    );
    final ghostBar = BoxDecoration(
      color: ghost,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xs),
      ),
    );

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppMotion.of(context, AppMotion.slow),
            curve: AppMotion.enter,
            builder: (context, grow, _) => SizedBox(
              height: _chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            if (bar.potential case final p?)
                              _Bar(share(p) * grow, ghostBar),
                            _Bar(share(bar.value) * grow, solarBar),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final bar in bars)
                Expanded(
                  child: Text(
                    bar.label ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: context.text.metricCaption.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              _LegendItem(decoration: solarBar, label: forecastLabel),
              if (showPotential)
                _LegendItem(
                  decoration: BoxDecoration(
                    color: ghost,
                    borderRadius: BorderRadius.circular(AppRadius.xs / 2),
                  ),
                  label: potentialLabel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.heightFactor, this.decoration);

  final double heightFactor;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: heightFactor,
    widthFactor: 1,
    child: DecoratedBox(decoration: decoration),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.decoration, required this.label});

  final BoxDecoration decoration;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: BbSolarForecastStrip._swatch,
        child: DecoratedBox(decoration: decoration),
      ),
      const SizedBox(width: AppSpacing.xs),
      Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    ],
  );
}
