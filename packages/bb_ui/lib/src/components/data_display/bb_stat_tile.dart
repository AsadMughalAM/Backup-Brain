import 'package:flutter/material.dart';

import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../surfaces/bb_card.dart';
import 'bb_metric.dart';
import 'bb_tone.dart';

/// One headline number in a card (DESIGN.md §10.4): icon in a tinted disc,
/// label, the value with its unit, and an optional delta line. Used in the dashboard's 2 × 2
/// grid, so the value scales down rather than overflow a narrow column.
///
/// ```dart
/// BbStatTile(
///   icon: BbIcons.solar,
///   tone: BbTone.solar,
///   label: l10n.solarToday,
///   value: '3.8',
///   unit: 'kWh',
///   delta: l10n.belowNormal(35),
/// )
/// ```
class BbStatTile extends StatelessWidget {
  const BbStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.delta,
    this.tone = BbTone.neutral,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;

  /// e.g. "−18% vs Mar".
  final String? delta;

  /// Colors the icon only. Status tones always come with the icon and the
  /// number, never color alone.
  final BbTone tone;

  static const _discSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textMuted;
    final delta = this.delta;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: BbCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _discSize,
              height: _discSize,
              decoration: BoxDecoration(
                color: tone.containerColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSizes.iconSm,
                color: tone.iconColor(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.xxs),
            BbMetric(value: value, unit: unit),
            if (delta != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                delta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
