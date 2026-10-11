import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';

/// Grid status and the one-tap outage log (DESIGN.md §10.6). Power on: navy
/// tint with a lightning icon. Power cut: muted fill with lightning-slash and
/// the time so far. Icon, words and fill all change, never color alone. The
/// trailing [actionLabel] says what a tap will log.
///
/// ```dart
/// BbGridStatusPill(
///   gridOn: true,
///   label: l10n.gridOn,              // "Light hai"
///   actionLabel: l10n.logPowerCut,   // "Light gayi?"
///   onTap: logger.toggle,
/// )
/// BbGridStatusPill(gridOn: false, label: l10n.gridOff, duration: '1h 12m',
///   actionLabel: l10n.logPowerBack, onTap: logger.toggle)
/// ```
class BbGridStatusPill extends StatelessWidget {
  const BbGridStatusPill({
    super.key,
    required this.gridOn,
    required this.label,
    required this.actionLabel,
    required this.onTap,
    this.duration,
  });

  final bool gridOn;

  /// "Light hai" / "Light gayi".
  final String label;

  /// Time without power so far, e.g. "1h 12m". Shown after the label.
  final String? duration;

  /// What a tap logs: "Light gayi?" / "Light aa gayi?".
  final String actionLabel;

  /// Null disables the pill (e.g. before the household has loaded).
  final VoidCallback? onTap;

  static const _height = 40.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final e = context.energy;
    final duration = this.duration;
    final base = gridOn ? c.secondaryContainer : c.surfaceMuted;
    final statusStyle = context.textTheme.labelLarge?.copyWith(
      color: c.textPrimary,
    );

    return Tappable(
      onTap: onTap,
      semanticLabel: [
        label,
        ?duration,
        actionLabel,
      ].join(', '),
      builder: (context, state) {
        final fill = state.pressed || state.hovered
            ? Color.alphaBlend(
                c.textPrimary.withValues(
                  alpha: state.pressed ? AppOpacity.pressed : AppOpacity.hover,
                ),
                base,
              )
            : base;
        final pill = FocusRing(
          visible: state.focused,
          radius: AppRadius.pill,
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            constraints: const BoxConstraints(minHeight: _height),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              children: [
                Icon(
                  gridOn ? BbIcons.gridOn : BbIcons.gridOff,
                  size: AppSizes.iconSm,
                  color: gridOn ? e.grid : e.offline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: label,
                      children: [
                        if (duration != null) ...[
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: duration,
                            style: context.text.metricSmall.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: statusStyle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  actionLabel,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: c.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: c.secondary,
                  ),
                ),
              ],
            ),
          ),
        );
        return state.enabled
            ? pill
            : Opacity(opacity: AppOpacity.disabled, child: pill);
      },
    );
  }
}
