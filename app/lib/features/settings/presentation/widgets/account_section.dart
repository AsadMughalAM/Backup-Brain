import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../auth/domain/auth_repository.dart';
import '../controllers/account_actions.dart';

/// Settings → Account: who is signed in, and sign out.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(accountProvider).value;
    final signingOut = ref.watch(accountActionsProvider);
    if (account == null) return const SizedBox.shrink();

    final who = account.displayName ?? account.email ?? l10n.googleAccount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.accountSection, style: context.textTheme.titleMedium),
        const BbGap.md(),
        BbCard(
          child: Column(
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
                      l10n.signedInAs(who),
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (account.email != null && account.email != who) ...[
                const BbGap.xs(),
                Text(
                  account.email!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
              const BbGap.lg(),
              BbButton.tonal(
                label: l10n.signOut,
                icon: BbIcons.signOut,
                loading: signingOut,
                onPressed: ref.read(accountActionsProvider.notifier).signOut,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
