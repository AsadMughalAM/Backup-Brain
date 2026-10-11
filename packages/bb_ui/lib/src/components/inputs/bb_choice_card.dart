import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/semantic/app_colors.dart';
import '../../foundations/tokens/elevation.dart';
import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';

/// One answer to a single-choice question, as a full-width card (DESIGN.md
/// §10.2): icon disc, title, optional hint and a radio mark. Selected =
/// navy-tinted fill plus a filled check, so the state never rests on color
/// alone; no borders.
///
/// ```dart
/// BbChoiceCard(
///   icon: BbIcons.solarPanel,
///   title: l10n.hasSolarYes,
///   subtitle: l10n.hasSolarYesHint,
///   selected: draft.hasSolar == true,
///   onSelected: () => controller.setHasSolar(true),
/// )
/// ```
class BbChoiceCard extends StatelessWidget {
  const BbChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onSelected,
    this.subtitle,
  });

  final IconData icon;
  final String title;

  /// A recognition cue ("Tall battery you top up with water"), not a
  /// repeat of the title.
  final String? subtitle;
  final bool selected;
  final VoidCallback? onSelected;

  static const _disc = 40.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = this.subtitle;
    return Tappable(
      onTap: onSelected,
      builder: (context, state) {
        final base = selected ? c.secondaryContainer : c.surface;
        final fill = state.pressed || state.hovered
            ? Color.alphaBlend(
                c.textPrimary.withValues(
                  alpha: state.pressed ? AppOpacity.pressed : AppOpacity.hover,
                ),
                base,
              )
            : base;
        return Semantics(
          selected: selected,
          inMutuallyExclusiveGroup: true,
          child: FocusRing(
            visible: state.focused,
            radius: AppRadius.lg,
            child: AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.fast),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: selected
                    ? const []
                    : AppElevation.level1.shadows(Theme.of(context).brightness),
              ),
              child: Row(
                children: [
                  Container(
                    width: _disc,
                    height: _disc,
                    decoration: BoxDecoration(
                      color: selected ? c.surface : c.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: AppSizes.iconSm, color: _accent(c)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.textTheme.titleSmall),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            subtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    selected ? BbIcons.radioOn : BbIcons.radioOff,
                    size: AppSizes.iconMd,
                    color: selected ? c.secondary : c.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _accent(AppColors c) => selected ? c.secondary : c.textPrimary;
}
