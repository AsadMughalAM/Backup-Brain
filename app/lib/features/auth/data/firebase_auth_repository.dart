import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;
  Future<void>? _googleInit;

  @override
  Stream<AccountInfo?> watchAccount() =>
      // userChanges (not authStateChanges) also fires when an anonymous
      // account is linked (same uid) or the display name is set.
      _auth.userChanges().map((user) {
        if (user == null) return null;
        final providers = user.providerData.map((p) => p.providerId).toSet();
        final kind = providers.contains(GoogleAuthProvider.PROVIDER_ID)
            ? AccountKind.google
            : providers.contains(EmailAuthProvider.PROVIDER_ID)
            ? AccountKind.email
            : AccountKind.anonymous;
        return AccountInfo(
          uid: user.uid,
          kind: kind,
          email: user.email,
          displayName: user.displayName,
        );
      });

  @override
  Future<void> continueWithGoogle() => _guard(() async {
    final user = _auth.currentUser;
    final anonymous = user != null && user.isAnonymous;
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      if (anonymous) {
        await _linkOrSwitch(
          () => _untilPopupAbandoned(user.linkWithPopup(provider)),
        );
      } else {
        await _untilPopupAbandoned(_auth.signInWithPopup(provider));
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
    if (anonymous) {
      await _linkOrSwitch(() => user.linkWithCredential(credential));
    } else {
      await _auth.signInWithCredential(credential);
    }
  });

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final user = _auth.currentUser;
    final result = user != null && user.isAnonymous
        ? await user.linkWithCredential(credential)
        : await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
    await result.user?.updateDisplayName(name);
  });

  @override
  Future<void> signInWithEmail(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> setRememberMe(bool remember) async {
    if (!kIsWeb) return;
    await _auth.setPersistence(
      remember ? Persistence.LOCAL : Persistence.SESSION,
    );
  }

  @override
  Future<void> signOut() => _guard(() async {
    await _auth.signOut();
    // So the next Google sign-in shows the account picker again.
    if (!kIsWeb && _googleInit != null) await GoogleSignIn.instance.signOut();
  });

  /// The Google account may already belong to another Backup Brain user
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

  /// Google's Cross-Origin-Opener-Policy hides the popup's `window.closed`
  /// from the SDK, so closing the popup never settles [popup]. If the page
  /// gets focus back and no result follows shortly, treat it as a cancel.
  /// A late success still signs in: the router reacts to the account stream.
  static Future<T> _untilPopupAbandoned<T>(Future<T> popup) {
    final abandoned = Completer<T>();
    Timer? grace;
    final listener = AppLifecycleListener(
      onResume: () {
        grace?.cancel();
        grace = Timer(const Duration(seconds: 3), () {
          if (abandoned.isCompleted) return;
          abandoned.completeError(
            FirebaseAuthException(code: 'popup-closed-by-user'),
          );
        });
      },
    );
    return Future.any([popup, abandoned.future]).whenComplete(() {
      grace?.cancel();
      listener.dispose();
    });
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
