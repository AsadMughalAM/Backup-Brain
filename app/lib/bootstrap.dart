import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_providers.dart';
import 'firebase_options.dart';

/// Run with `--dart-define=USE_EMULATORS=true` to use the local Emulator
/// Suite instead of `backup-brain-dev` (TECH_STACK.md §7.8).
const _useEmulators = bool.fromEnvironment('USE_EMULATORS');

/// Public reCAPTCHA v3 site key for a web build outside development. Unset,
/// the web build uses the App Check debug provider.
const _recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase AI Logic (the F9 assistant) only answers requests that carry an
  // App Check token. Debug builds print a debug token on first run (browser
  // console / logcat); add it once under App Check → Manage debug tokens.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerWeb: kDebugMode || _recaptchaSiteKey.isEmpty
        ? WebDebugProvider()
        : ReCaptchaV3Provider(_recaptchaSiteKey),
  );

  if (_useEmulators) {
    // The Android emulator reaches the host machine at 10.0.2.2.
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }

  // Offline persistence is on by default on Android/iOS; the cache is what
  // makes the countdown work during load-shedding. The web build is only a
  // dev preview, but give it a persistent cache too so it behaves the same.
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(overrides: appOverrides(prefs), child: const App()));
}
