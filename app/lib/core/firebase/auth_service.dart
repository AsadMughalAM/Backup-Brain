import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_providers.dart';

/// Anonymous sign-in at first launch (TECH_STACK.md §2.1). Firebase keeps
/// the user on the device, so after the first online launch the app works
/// offline with the same uid.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Returns the uid, or null if signing in failed (usually: offline on the
  /// very first launch).
  Future<String?> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user?.uid;
    } on FirebaseAuthException {
      return null;
    }
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);
