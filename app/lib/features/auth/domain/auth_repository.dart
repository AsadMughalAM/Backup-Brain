import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountKind { anonymous, email, google }

/// Who is signed in. The app requires a Google or email account; an
/// anonymous account left over from an older version is linked on sign-up,
/// so its uid — and every Firestore document under it — stays.
class AccountInfo {
  const AccountInfo({
    required this.uid,
    required this.kind,
    this.email,
    this.displayName,
  });

  final String uid;
  final AccountKind kind;
  final String? email;
  final String? displayName;

  bool get isAnonymous => kind == AccountKind.anonymous;

  /// For the greeting: the first word of the name, if there is one.
  String? get firstName {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }
}

enum AuthFailureCode {
  cancelled,
  invalidEmail,
  wrongCredentials,
  emailInUse,
  weakPassword,
  network,
  tooManyRequests,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;

  @override
  String toString() => 'AuthFailure($code)';
}

/// All methods throw [AuthFailure] on failure.
abstract interface class AuthRepository {
  /// Null when nobody is signed in. Also emits when an account is linked or
  /// its name changes.
  Stream<AccountInfo?> watchAccount();

  /// Google sign-in. Links a leftover anonymous account; if the Google
  /// account already belongs to a user, signs in to that one.
  Future<void> continueWithGoogle();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signInWithEmail(String email, String password);

  Future<void> sendPasswordReset(String email);

  /// "Remember me". Only the web build can forget a session when the tab
  /// closes; on Android the session always persists.
  Future<void> setRememberMe(bool remember);

  Future<void> signOut();
}

/// Bound to the Firebase implementation in `app/app_providers.dart`.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final accountProvider = StreamProvider<AccountInfo?>(
  (ref) => ref.watch(authRepositoryProvider).watchAccount(),
);

/// Signed in with a real (non-anonymous) account — what the router gates on.
final isSignedInProvider = Provider<bool?>((ref) {
  final account = ref.watch(accountProvider);
  if (!account.hasValue) return null; // still loading
  final info = account.value;
  return info != null && !info.isAnonymous;
});
