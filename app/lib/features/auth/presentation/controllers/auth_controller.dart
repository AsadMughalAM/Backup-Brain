import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth_repository.dart';

class AuthState {
  const AuthState({this.busy = false, this.failure, this.resetSentTo});

  final bool busy;

  /// Shown to the user; null when the last action worked or was cancelled.
  final AuthFailureCode? failure;

  /// Set after a password-reset email was sent.
  final String? resetSentTo;
}

/// Sign-up / login actions. Navigation is not done here: once an account
/// is signed in, the router moves to Home by itself.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> continueWithGoogle() => _run(_repo.continueWithGoogle);

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    bool rememberMe = true,
  }) => _run(() async {
    await _repo.setRememberMe(rememberMe);
    await _repo.signUpWithEmail(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
  });

  Future<bool> login(String email, String password, {bool rememberMe = true}) =>
      _run(() async {
        await _repo.setRememberMe(rememberMe);
        await _repo.signInWithEmail(email.trim(), password);
      });

  Future<bool> sendPasswordReset(String email) async {
    final ok = await _run(() => _repo.sendPasswordReset(email.trim()));
    if (ok) state = AuthState(resetSentTo: email.trim());
    return ok;
  }

  void clearMessages() => state = const AuthState();

  Future<bool> _run(Future<void> Function() action) async {
    state = const AuthState(busy: true);
    try {
      await action();
      state = const AuthState();
      return true;
    } on AuthFailure catch (e) {
      // Closing the Google picker is a choice, not an error.
      state = AuthState(
        failure: e.code == AuthFailureCode.cancelled ? null : e.code,
      );
      return false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
