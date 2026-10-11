import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../../domain/auth_repository.dart';
import '../controllers/account_controller.dart';
import '../widgets/auth_messages.dart';

/// Settings → Account. Anonymous users are invited to save their data;
/// signed-in users see who they are and can sign out.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountProvider).value;
    final state = ref.watch(accountControllerProvider);
    final controller = ref.read(accountControllerProvider.notifier);
    final failure = state.failure;
    if (account == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.accountSection, style: context.textTheme.titleMedium),
        const BbGap.md(),
        if (failure != null) ...[
          BbBanner(
            tone: BbBannerTone.warning,
            message: authErrorText(l10n, failure),
          ),
          const BbGap.md(),
        ],
        BbCard(
          child: account.isAnonymous
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.saveDataTitle,
                      style: context.textTheme.titleSmall,
                    ),
                    const BbGap.xs(),
                    Text(
                      l10n.saveDataBody,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                    const BbGap.lg(),
                    BbButton.secondary(
                      label: l10n.continueWithGoogle,
                      icon: BbIcons.google,
                      expand: true,
                      loading: state.busy,
                      onPressed: controller.continueWithGoogle,
                    ),
                    const BbGap.sm(),
                    BbButton.tonal(
                      label: l10n.useEmail,
                      icon: BbIcons.email,
                      expand: true,
                      onPressed: state.busy
                          ? null
                          : () => context.push(Routes.signIn),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          BbIcons.account,
                          size: AppSizes.iconSm,
                          color: context.colors.textMuted,
                        ),
                        const BbGap.sm(),
                        Expanded(
                          child: Text(
                            l10n.signedInAs(
                              account.email ?? l10n.googleAccount,
                            ),
                            style: context.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const BbGap.lg(),
                    BbButton.tonal(
                      label: l10n.signOut,
                      icon: BbIcons.signOut,
                      loading: state.busy,
                      onPressed: controller.signOut,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
