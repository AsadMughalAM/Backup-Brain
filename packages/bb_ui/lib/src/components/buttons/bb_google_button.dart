import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundations/tokens/motion.dart';
import '../../foundations/tokens/opacity.dart';
import '../../foundations/tokens/radius.dart';
import '../../foundations/tokens/spacing.dart';
import '../../theme/context_extensions.dart';
import '../_internal/tappable.dart';
import '../feedback/bb_spinner.dart';

/// "Continue with Google" (DESIGN.md §10.1): outlined pill with Google's
/// own four-color G, as Google's sign-in branding requires. The colors live
/// in the SVG asset, not in code.
///
/// ```dart
/// BbGoogleButton(label: l10n.continueWithGoogle, onPressed: signIn)
/// ```
class BbGoogleButton extends StatelessWidget {
  const BbGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.pill);
    final disabled = onPressed == null;

    return Tappable(
      onTap: disabled || loading ? null : onPressed,
      builder: (context, s) {
        Widget button = AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.fast),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: radius,
            border: Border.all(color: c.outlineVariant),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            color: c.textPrimary.withValues(
              alpha: s.pressed
                  ? AppOpacity.pressed
                  : s.hovered
                  ? AppOpacity.hover
                  : 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                IconTheme.merge(
                  data: IconThemeData(color: c.textPrimary),
                  child: const BbSpinner(size: BbSpinnerSize.md),
                )
              else
                SvgPicture.asset(
                  'assets/images/google_g.svg',
                  package: 'bb_ui',
                  width: 20,
                  height: 20,
                  excludeFromSemantics: true,
                ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
        button = FocusRing(
          visible: s.focused,
          radius: AppRadius.pill,
          child: button,
        );
        return disabled
            ? Opacity(opacity: AppOpacity.disabled, child: button)
            : button;
      },
    );
  }
}
