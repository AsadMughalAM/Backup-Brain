import 'package:flutter/material.dart';

import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/sizes.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';

enum BbIconButtonVariant {
  /// No fill — app bar actions.
  standard,

  /// 40 px `surfaceMuted` circle.
  tonal,

  /// 64 px yellow circle inside a thin yellow ring — the intro's "next"
  /// arrow. Counts as the screen's one primary action.
  hero,
}

/// Icon-only button with a 48 × 48 hit area and a required [tooltip], which
/// is also its screen-reader label (DESIGN.md §10.1).
///
/// ```dart
/// BbIconButton(icon: BbIcons.themeDark, tooltip: l10n.switchTheme, onPressed: toggle)
/// BbIconButton(icon: BbIcons.forward, tooltip: l10n.next, variant: BbIconButtonVariant.hero, onPressed: next)
/// ```
class BbIconButton extends StatelessWidget {
  const BbIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = BbIconButtonVariant.standard,
  });

  final IconData icon;
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final BbIconButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hero = variant == BbIconButtonVariant.hero;
    final diameter = hero ? 64.0 : 40.0;
    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Tappable(
        onTap: onPressed,
        semanticLabel: tooltip,
        builder: (context, s) {
          final base = switch (variant) {
            BbIconButtonVariant.standard => colors.surfaceMuted.withValues(
              alpha: 0,
            ),
            BbIconButtonVariant.tonal => colors.surfaceMuted,
            BbIconButtonVariant.hero => colors.primary,
          };
          final overlay = colors.textPrimary.withValues(
            alpha: s.pressed
                ? AppOpacity.pressed
                : s.hovered
                ? AppOpacity.hover
                : 0,
          );
          Widget button = AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.fast),
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
            foregroundDecoration: BoxDecoration(
              color: overlay,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: hero ? AppSizes.iconLg : AppSizes.iconMd,
              color: hero ? colors.textOnPrimary : colors.textPrimary,
            ),
          );
          if (hero) {
            button = Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary, width: 2),
              ),
              child: button,
            );
          }
          button = FocusRing(
            visible: s.focused,
            radius: hero ? 38 : diameter / 2,
            child: button,
          );
          return s.enabled
              ? button
              : Opacity(opacity: AppOpacity.disabled, child: button);
        },
      ),
    );
  }
}
