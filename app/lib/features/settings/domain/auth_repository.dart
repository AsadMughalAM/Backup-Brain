import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountKind { anonymous, email, google }

/// Who is signed in. Everyone starts anonymous; signing in links that
/// account, so the uid — and every Firestore document under it — stays.
class AccountInfo {
  const AccountInfo({required this.kind, this.email});

  final AccountKind kind;
  final String? email;

  bool get isAnonymous => kind == AccountKind.anonymous;
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
  /// Null when nobody is signed in (not even anonymously).
  Stream<AccountInfo?> watchAccount();

  /// Links the current anonymous account to Google. If that Google account
  /// already belongs to another user, signs in to it instead.
  Future<void> continueWithGoogle();

  /// Turns the current anonymous account into an email account.
  Future<void> createWithEmail(String email, String password);

  /// Signs in to an existing email account (replaces the current one).
  Future<void> signInWithEmail(String email, String password);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

/// Bound to the Firebase implementation in `app/app_providers.dart`.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final accountProvider = StreamProvider<AccountInfo?>(
  (ref) => ref.watch(authRepositoryProvider).watchAccount(),
);
