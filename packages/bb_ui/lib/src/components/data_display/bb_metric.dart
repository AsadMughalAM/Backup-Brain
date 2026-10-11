import 'package:flutter/material.dart';

import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import 'bb_tone.dart';

enum BbMetricSize { hero, large, medium, small }

/// A live number with its unit (DESIGN.md §3.5): the value in Geist with
/// tabular figures, the unit one step smaller in `textMuted`,
/// baseline-aligned. Never truncated.
///
/// ```dart
/// BbMetric(value: '420', unit: 'W')
/// BbMetric(value: '+2h 10m', size: BbMetricSize.small, tone: BbTone.success)
/// ```
class BbMetric extends StatelessWidget {
  const BbMetric({
    super.key,
    required this.value,
    this.unit,
    this.size = BbMetricSize.large,
    this.tone = BbTone.neutral,
  });

  /// Already formatted by the app (`core/utils` formatters).
  final String value;
  final String? unit;
  final BbMetricSize size;
  final BbTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final (valueStyle, unitStyle) = switch (size) {
      BbMetricSize.hero => (t.metricHero, t.metricLarge),
      BbMetricSize.large => (t.metricLarge, t.metricMedium),
      BbMetricSize.medium => (t.metricMedium, t.metricSmall),
      BbMetricSize.small => (t.metricSmall, t.metricCaption),
    };
    final unit = this.unit;
    final metric = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          softWrap: false,
          style: valueStyle.copyWith(color: tone.textColor(context)),
        ),
        if (unit != null && unit.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xxs),
          Text(
            unit,
            softWrap: false,
            style: unitStyle.copyWith(color: context.colors.textMuted),
          ),
        ],
      ],
    );
    // Numbers are never truncated: shrink to fit instead. Only the hero
    // size may also cap text scaling, at 1.3× (DESIGN.md §3.5).
    final fitted = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: metric,
    );
    return size == BbMetricSize.hero
        ? MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: fitted)
        : fitted;
  }
}
