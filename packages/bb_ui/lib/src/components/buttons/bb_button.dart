import 'package:flutter/material.dart';

import '../../foundations/semantic/app_colors.dart';
import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/sizes.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';
import '../feedback/bb_spinner.dart';

enum BbButtonVariant {
  /// Coral. **One per screen** — the main task.
  primary,

  /// Indigo. Strong secondary actions.
  secondary,

  /// Muted fill. Neutral actions ("Edit", "Add appliance").
  tonal,

  /// No fill, link color. Low emphasis ("See all", "Skip").
  ghost,

  /// Red. Destructive actions only.
  danger,
}

enum BbButtonSize {
  sm(40),
  md(48),

  /// Sticky bottom CTA; usually with `expand: true`.
  lg(56);

  const BbButtonSize(this.height);
  final double height;
}

/// The app's button (DESIGN.md §10.1). Handles pressed, hover, focus,
/// disabled (`onPressed: null`) and loading states itself.
///
/// ```dart
/// BbButton(
///   label: l10n.whatToTurnOff,
///   icon: BbIcons.loads,
///   onPressed: controller.openPlanner,
/// )
/// BbButton.secondary(label: l10n.batteryKharab, onPressed: ...)
/// BbButton(label: l10n.findShops, loading: true, loadingLabel: l10n.findingShops, onPressed: ...)
/// ```
class BbButton extends StatelessWidget {
  const BbButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BbButtonVariant.primary,
    this.size = BbButtonSize.md,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
  });

  const BbButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = BbButtonSize.md,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
  }) : variant = BbButtonVariant.secondary;

  const BbButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = BbButtonSize.md,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
  }) : variant = BbButtonVariant.tonal;

  const BbButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = BbButtonSize.md,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
  }) : variant = BbButtonVariant.ghost;

  const BbButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = BbButtonSize.md,
    this.icon,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
  }) : variant = BbButtonVariant.danger;

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final BbButtonVariant variant;
  final BbButtonSize size;

  /// Leading icon only (20 px).
  final IconData? icon;

  /// Shows a spinner in place of the icon and ignores taps.
  final bool loading;

  /// Progressive label while [loading], e.g. "Finding shops…".
  final String? loadingLabel;

  /// Fill the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, content) = _palette(colors);
    final disabled = onPressed == null;
    final radius = BorderRadius.circular(AppRadius.pill);

    return Tappable(
      onTap: disabled || loading ? null : onPressed,
      builder: (context, s) {
        final overlay = colors.textPrimary.withValues(
          alpha: !s.enabled
              ? 0
              : s.pressed
              ? AppOpacity.pressed
              : s.hovered
              ? AppOpacity.hover
              : 0,
        );
        final leading = loading
            ? const BbSpinner(size: BbSpinnerSize.md)
            : icon == null
            ? null
            : Icon(icon, size: AppSizes.iconSm);

        Widget button = AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.fast),
          curve: AppMotion.enter,
          constraints: BoxConstraints(minHeight: size.height),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: fill, borderRadius: radius),
          foregroundDecoration: BoxDecoration(
            color: overlay,
            borderRadius: radius,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: content, size: AppSizes.iconSm),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    loading ? (loadingLabel ?? label) : label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: content,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        button = AnimatedScale(
          scale: s.pressed ? 0.98 : 1,
          duration: AppMotion.of(context, AppMotion.fast),
          curve: AppMotion.enter,
          child: FocusRing(
            visible: s.focused,
            radius: AppRadius.pill,
            child: button,
          ),
        );
        if (disabled) {
          button = Opacity(opacity: AppOpacity.disabled, child: button);
        }
        return expand
            ? SizedBox(width: double.infinity, child: button)
            : button;
      },
    );
  }

  (Color fill, Color content) _palette(AppColors c) => switch (variant) {
    BbButtonVariant.primary => (c.primary, c.textOnPrimary),
    BbButtonVariant.secondary => (c.secondary, c.onSecondary),
    BbButtonVariant.tonal => (c.surfaceMuted, c.textPrimary),
    BbButtonVariant.ghost => (c.link.withValues(alpha: 0), c.link),
    BbButtonVariant.danger => (c.danger, c.onDanger),
  };
}
