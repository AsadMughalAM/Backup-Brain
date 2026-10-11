import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/semantic/app_colors.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../buttons/bb_icon_button.dart';

enum BbBannerTone { info, success, warning, danger }

/// Inline message (DESIGN.md §8.7): container color + Fill status icon +
/// text, so meaning never rests on color alone.
///
/// `danger` banners are for safety (overload, battery swelling/heat) and are
/// never dismissible, even if [onDismiss] is given.
///
/// ```dart
/// BbBanner(tone: BbBannerTone.danger, title: l10n.overloadTitle, message: l10n.overloadBody)
/// BbBanner(message: l10n.pricesUpdated, onDismiss: hide, dismissLabel: l10n.close)
/// ```
class BbBanner extends StatelessWidget {
  const BbBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = BbBannerTone.info,
    this.onDismiss,
    this.dismissLabel,
  }) : assert(
         onDismiss == null || dismissLabel != null,
         'A dismissible banner needs a dismissLabel for screen readers.',
       );

  final String message;
  final String? title;
  final BbBannerTone tone;
  final VoidCallback? onDismiss;
  final String? dismissLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (container, accent, icon) = _style(colors);
    final title = this.title;
    final canDismiss = onDismiss != null && tone != BbBannerTone.danger;
    final urgent = tone == BbBannerTone.danger || tone == BbBannerTone.warning;

    final content = Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        // Leave room for the overlaid close button.
        end: canDismiss ? AppSizes.minTouchTarget : AppSpacing.lg,
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aligned to the first text line, not the block's center.
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: AppSizes.iconSm, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      liveRegion: urgent,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        // Overlaid in the corner so the 48 dp hit area doesn't make a
        // one-line banner taller; minHeight keeps that area inside the box.
        child: canDismiss
            ? ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.minTouchTarget,
                ),
                child: Stack(
                  children: [
                    content,
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: BbIconButton(
                        icon: BbIcons.close,
                        tooltip: dismissLabel!,
                        onPressed: onDismiss,
                      ),
                    ),
                  ],
                ),
              )
            : content,
      ),
    );
  }

  (Color container, Color accent, IconData icon) _style(
    AppColors c,
  ) => switch (tone) {
    BbBannerTone.info => (c.secondaryContainer, c.info, BbIcons.info),
    BbBannerTone.success => (c.successContainer, c.success, BbIcons.success),
    BbBannerTone.warning => (c.warningContainer, c.warning, BbIcons.warning),
    BbBannerTone.danger => (c.dangerContainer, c.danger, BbIcons.danger),
  };
}
