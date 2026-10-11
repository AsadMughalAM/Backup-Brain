import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_repository.dart';

/// Settings → Account actions. True while signing out.
class AccountActions extends Notifier<bool> {
  @override
  bool build() => false;

  /// The router returns to the intro once the account is gone.
  Future<void> signOut() async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AuthFailure {
      // Signing out only fails without a session; nothing to show.
    } finally {
      state = false;
    }
  }
}

final accountActionsProvider = NotifierProvider<AccountActions, bool>(
  AccountActions.new,
);
