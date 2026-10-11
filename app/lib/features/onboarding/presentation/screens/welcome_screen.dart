import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../controllers/onboarding_controller.dart';

/// First launch. For now it offers the demo household; the full setup form
/// (city → solar? → battery → appliances) is the next step.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(onboardingControllerProvider);
    final muted = context.colors.textMuted;

    return BbScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          children: [
            Icon(
              BbIcons.countdown,
              size: AppSizes.iconXl,
              color: context.colors.secondary,
            ),
            const BbGap.xl(),
            Text(l10n.welcomeTitle, style: context.textTheme.displaySmall),
            const BbGap.md(),
            Text(
              l10n.welcomeBody,
              style: context.textTheme.bodyLarge?.copyWith(color: muted),
            ),
            const BbGap.xxl(),
            if (status == OnboardingStatus.needsInternet) ...[
              BbBanner(
                tone: BbBannerTone.warning,
                message: l10n.needsInternetFirstTime,
              ),
              const BbGap.lg(),
            ],
            BbButton(
              label: l10n.tryDemo,
              loadingLabel: l10n.tryDemoLoading,
              loading: status == OnboardingStatus.working,
              size: BbButtonSize.lg,
              expand: true,
              onPressed: () =>
                  ref.read(onboardingControllerProvider.notifier).startDemo(),
            ),
            const BbGap.md(),
            Text(
              l10n.welcomeOwnSetupSoon,
              style: context.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
