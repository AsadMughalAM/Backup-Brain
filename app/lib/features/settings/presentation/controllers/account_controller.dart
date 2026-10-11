import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth_repository.dart';

class AccountState {
  const AccountState({this.busy = false, this.failure, this.resetSentTo});

  final bool busy;

  /// Shown to the user; null when the last action worked or was cancelled.
  final AuthFailureCode? failure;

  /// Set after a password-reset email was sent.
  final String? resetSentTo;
}

/// Sign-in actions. Each returns true on success so the screen can close.
/// Unlike data writes, these need the network and are awaited.
class AccountController extends Notifier<AccountState> {
  @override
  AccountState build() => const AccountState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> continueWithGoogle() => _run(_repo.continueWithGoogle);

  Future<bool> createWithEmail(String email, String password) =>
      _run(() => _repo.createWithEmail(email.trim(), password));

  Future<bool> signInWithEmail(String email, String password) =>
      _run(() => _repo.signInWithEmail(email.trim(), password));

  Future<bool> sendPasswordReset(String email) async {
    final ok = await _run(() => _repo.sendPasswordReset(email.trim()));
    if (ok) state = AccountState(resetSentTo: email.trim());
    return ok;
  }

  Future<bool> signOut() => _run(_repo.signOut);

  void clearMessages() => state = const AccountState();

  Future<bool> _run(Future<void> Function() action) async {
    state = const AccountState(busy: true);
    try {
      await action();
      state = const AccountState();
      return true;
    } on AuthFailure catch (e) {
      // Closing the Google picker is a choice, not an error.
      state = AccountState(
        failure: e.code == AuthFailureCode.cancelled ? null : e.code,
      );
      return false;
    }
  }
}

final accountControllerProvider =
    NotifierProvider<AccountController, AccountState>(AccountController.new);
