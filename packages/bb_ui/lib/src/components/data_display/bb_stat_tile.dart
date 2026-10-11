import 'package:flutter/material.dart';

import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';
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
    this.onTap,
    this.tapLabel,
  }) : assert(
         onTap == null || tapLabel != null,
         'A tappable tile needs a label saying what the tap does',
       );

  final IconData icon;
  final String label;
  final String value;
  final String? unit;

  /// e.g. "−18% vs Mar".
  final String? delta;

  /// Colors the icon only. Status tones always come with the icon and the
  /// number, never color alone.
  final BbTone tone;

  /// Makes the tile a button (e.g. Battery → "Check battery %").
  final VoidCallback? onTap;

  /// Added to what screen readers hear, after the value.
  final String? tapLabel;

  static const _discSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    if (onTap == null) return _tile(context);
    final c = context.colors;
    return Tappable(
      onTap: onTap,
      builder: (context, s) => Semantics(
        hint: tapLabel,
        child: FocusRing(
          visible: s.focused,
          radius: AppRadius.lg,
          child: Stack(
            children: [
              _tile(context),
              // Press and hover tint the surface; never a border.
              if (s.pressed || s.hovered)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.textPrimary.withValues(
                          alpha: s.pressed
                              ? AppOpacity.pressed
                              : AppOpacity.hover,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context) {
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
