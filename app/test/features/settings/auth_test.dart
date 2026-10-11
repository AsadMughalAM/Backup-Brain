import 'dart:async';

import 'package:backup_brain/app/l10n/app_localizations.dart';
import 'package:backup_brain/app/theme_mode/theme_mode_controller.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/settings/data/firebase_auth_repository.dart';
import 'package:backup_brain/features/settings/domain/auth_repository.dart';
import 'package:backup_brain/features/settings/presentation/controllers/account_controller.dart';
import 'package:backup_brain/features/settings/presentation/screens/settings_screen.dart';
import 'package:backup_brain/features/settings/presentation/screens/sign_in_screen.dart';
import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.account, this.failWith});

  AccountInfo? account;
  AuthFailureCode? failWith;
  final calls = <String>[];
  final _changes = StreamController<AccountInfo?>.broadcast();

  Future<void> _act(String call, AccountInfo? after) async {
    calls.add(call);
    final code = failWith;
    if (code != null) throw AuthFailure(code);
    _changes.add(account = after);
  }

  @override
  Stream<AccountInfo?> watchAccount() async* {
    yield account;
    yield* _changes.stream;
  }

  @override
  Future<void> continueWithGoogle() =>
      _act('google', const AccountInfo(kind: AccountKind.google));

  @override
  Future<void> createWithEmail(String email, String password) =>
      _act('create $email', AccountInfo(kind: AccountKind.email, email: email));

  @override
  Future<void> signInWithEmail(String email, String password) =>
      _act('signIn $email', AccountInfo(kind: AccountKind.email, email: email));

  @override
  Future<void> sendPasswordReset(String email) => _act('reset $email', account);

  @override
  Future<void> signOut() => _act('signOut', null);
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  FakeAuthRepository auth,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth),
      ],
      child: Consumer(
        // A real router: screens close themselves with go_router.
        builder: (context, ref, _) => MaterialApp.router(
          theme: AppTheme.light(),
          themeMode: ref.watch(themeModeProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [GoRoute(path: '/', builder: (_, _) => screen)],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(BbTextField)),
  matching: find.byType(TextField),
);

void main() {
  group('Firebase error codes', () {
    test('map to friendly failures', () {
      expect(
        mapFirebaseAuthCode('invalid-credential'),
        AuthFailureCode.wrongCredentials,
      );
      expect(
        mapFirebaseAuthCode('wrong-password'),
        AuthFailureCode.wrongCredentials,
      );
      expect(
        mapFirebaseAuthCode('email-already-in-use'),
        AuthFailureCode.emailInUse,
      );
      expect(
        mapFirebaseAuthCode('network-request-failed'),
        AuthFailureCode.network,
      );
      expect(
        mapFirebaseAuthCode('popup-closed-by-user'),
        AuthFailureCode.cancelled,
      );
      expect(mapFirebaseAuthCode('something-new'), AuthFailureCode.unknown);
    });
  });

  group('AccountController', () {
    test('success clears state; cancel is silent; failure is kept', () async {
      final auth = FakeAuthRepository(
        account: const AccountInfo(kind: AccountKind.anonymous),
      );
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);
      final controller = container.read(accountControllerProvider.notifier);

      expect(await controller.continueWithGoogle(), isTrue);
      expect(container.read(accountControllerProvider).failure, isNull);

      auth.failWith = AuthFailureCode.cancelled;
      expect(await controller.continueWithGoogle(), isFalse);
      expect(container.read(accountControllerProvider).failure, isNull);

      auth.failWith = AuthFailureCode.network;
      expect(await controller.continueWithGoogle(), isFalse);
      expect(
        container.read(accountControllerProvider).failure,
        AuthFailureCode.network,
      );
    });
  });

  group('SignInScreen', () {
    testWidgets('validates email and password before calling Firebase', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await _pump(tester, const SignInScreen(), auth);

      await tester.enterText(_field('Email'), 'not-an-email');
      await tester.enterText(_field('Password'), '123');
      await tester.tap(find.text('Create account').last);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 6 characters.'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('valid details create the account (trimmed email)', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      await _pump(tester, const SignInScreen(), auth);

      await tester.enterText(_field('Email'), '  asad@example.pk ');
      await tester.enterText(_field('Password'), 'secret12');
      await tester.tap(find.text('Create account').last);
      await tester.pumpAndSettle();

      expect(auth.calls, ['create asad@example.pk']);
    });

    testWidgets('a taken email shows a friendly, actionable message', (
      tester,
    ) async {
      final auth = FakeAuthRepository(failWith: AuthFailureCode.emailInUse);
      await _pump(tester, const SignInScreen(), auth);

      await tester.enterText(_field('Email'), 'asad@example.pk');
      await tester.enterText(_field('Password'), 'secret12');
      await tester.tap(find.text('Create account').last);
      await tester.pumpAndSettle();

      expect(
        find.text('This email already has an account. Sign in instead.'),
        findsOneWidget,
      );
    });

    testWidgets('sign-in mode offers password reset', (tester) async {
      final auth = FakeAuthRepository();
      await _pump(
        tester,
        const SignInScreen(initialMode: SignInMode.signIn),
        auth,
      );
      await tester.enterText(_field('Email'), 'asad@example.pk');
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(auth.calls, ['reset asad@example.pk']);
      expect(
        find.text('We sent a password reset link to asad@example.pk.'),
        findsOneWidget,
      );
    });
  });

  group('Settings account section', () {
    testWidgets('anonymous users are invited to save their data', (
      tester,
    ) async {
      final auth = FakeAuthRepository(
        account: const AccountInfo(kind: AccountKind.anonymous),
      );
      await _pump(tester, const SettingsScreen(), auth);
      expect(find.text('Save your data'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('signed-in users see who they are and can sign out', (
      tester,
    ) async {
      final auth = FakeAuthRepository(
        account: const AccountInfo(
          kind: AccountKind.email,
          email: 'asad@example.pk',
        ),
      );
      await _pump(tester, const SettingsScreen(), auth);
      expect(find.text('Signed in as asad@example.pk'), findsOneWidget);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['signOut']);
    });
  });
}
