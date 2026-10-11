import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;
  Future<void>? _googleInit;

  @override
  Stream<AccountInfo?> watchAccount() =>
      // userChanges (not authStateChanges) also fires when an anonymous
      // account is linked, which keeps the same uid.
      _auth.userChanges().map((user) {
        if (user == null) return null;
        final providers = user.providerData.map((p) => p.providerId).toSet();
        final kind = providers.contains(GoogleAuthProvider.PROVIDER_ID)
            ? AccountKind.google
            : providers.contains(EmailAuthProvider.PROVIDER_ID)
            ? AccountKind.email
            : AccountKind.anonymous;
        return AccountInfo(kind: kind, email: user.email);
      });

  @override
  Future<void> continueWithGoogle() => _guard(() async {
    final user = _auth.currentUser;
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      if (user != null && user.isAnonymous) {
        await _linkOrSwitch(() => user.linkWithPopup(provider));
      } else {
        await _auth.signInWithPopup(provider);
      }
      return;
    }
    // Android: native account picker (Credential Manager). The web client id
    // comes from google-services.json.
    await (_googleInit ??= GoogleSignIn.instance.initialize());
    final account = await GoogleSignIn.instance.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    if (user != null && user.isAnonymous) {
      await _linkOrSwitch(() => user.linkWithCredential(credential));
    } else {
      await _auth.signInWithCredential(credential);
    }
  });

  @override
  Future<void> createWithEmail(String email, String password) =>
      _guard(() async {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        final user = _auth.currentUser;
        if (user != null && user.isAnonymous) {
          await user.linkWithCredential(credential);
        } else {
          await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        }
      });

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> signOut() => _guard(() async {
    await _auth.signOut();
    // So the next Google sign-in shows the account picker again.
    if (!kIsWeb && _googleInit != null) await GoogleSignIn.instance.signOut();
  });

  /// The Google account may already be linked to another Backup Brain user
  /// (e.g. from an older phone). Then sign in to that one: its data wins.
  Future<void> _linkOrSwitch(Future<UserCredential> Function() link) async {
    try {
      await link();
    } on FirebaseAuthException catch (e) {
      final existing = e.credential;
      if (e.code == 'credential-already-in-use' && existing != null) {
        await _auth.signInWithCredential(existing);
      } else {
        rethrow;
      }
    }
  }

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on GoogleSignInException catch (e) {
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.canceled
            ? AuthFailureCode.cancelled
            : AuthFailureCode.unknown,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(mapFirebaseAuthCode(e.code));
    }
  }
}

@visibleForTesting
AuthFailureCode mapFirebaseAuthCode(String code) => switch (code) {
  'invalid-email' => AuthFailureCode.invalidEmail,
  'wrong-password' ||
  'invalid-credential' ||
  'user-not-found' ||
  'user-disabled' => AuthFailureCode.wrongCredentials,
  'email-already-in-use' ||
  'provider-already-linked' => AuthFailureCode.emailInUse,
  'weak-password' => AuthFailureCode.weakPassword,
  'network-request-failed' => AuthFailureCode.network,
  'too-many-requests' => AuthFailureCode.tooManyRequests,
  'popup-closed-by-user' ||
  'cancelled-popup-request' ||
  'web-context-canceled' => AuthFailureCode.cancelled,
  _ => AuthFailureCode.unknown,
};
