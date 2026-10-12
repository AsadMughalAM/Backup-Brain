import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';

/// The sign-in "sky" — the reference layout in Backup Brain's colors: indigo
/// fading through light indigo into the mist background (never through grey), with a
/// crisp sun. DESIGN.md §2.7 allows this one gradient on auth screens.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child, this.skyEnd = 0.5});

  final Widget child;

  /// Fraction of the height where the sky has fully faded into the mist background.
  final double skyEnd;

  /// Text drawn directly on the sky (the big titles).
  static Color titleColor(BuildContext context) => context.isDarkTheme
      ? context.colors.onSecondaryContainer
      : context.colors.onSecondary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Dark mode: deep indigo instead of the light-indigo `secondary`, so the
    // sky stays darker than the content below it.
    final top = context.isDarkTheme ? c.secondaryContainer : c.secondary;
    final middle = context.isDarkTheme ? c.surface : c.secondaryContainer;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [top, middle, c.background],
                stops: [0, skyEnd * 0.8, skyEnd],
              ),
            ),
          ),
        ),
        // Sun: a crisp disc, half off the corner and clear of the title.
        PositionedDirectional(
          top: -36,
          end: -36,
          width: 112,
          height: 112,
          child: ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.primary,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Sign-up / login frame: back circle, big centered title on the sky, then
/// the form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: AuthBackground(
        child: SafeArea(
          child: BbPagePadding(
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.xxl,
              ),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BbIconButton(
                    icon: BbIcons.back,
                    tooltip: l10n.back,
                    variant: BbIconButtonVariant.tonal,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(Routes.setup),
                  ),
                ),
                const BbGap.xxxl(),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AuthBackground.titleColor(context),
                  ),
                ),
                const BbGap.xxxl(),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Or" between the email form and Google.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

/// "Already have an account? Login" — the action is a real button, so it
/// gets a 48 dp target and focus.
class AccountPrompt extends StatelessWidget {
  const AccountPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  final String question;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        question,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colors.textMuted,
        ),
      ),
      BbButton.ghost(
        label: action,
        size: BbButtonSize.sm,
        onPressed: onPressed,
      ),
    ],
  );
}

/// "Remember me" — only meaningful on web, so screens show it there only.
class RememberMe extends StatelessWidget {
  const RememberMe({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text(label, style: context.textTheme.bodyMedium),
        ),
      ],
    ),
  );
}
