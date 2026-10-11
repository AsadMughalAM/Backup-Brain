import 'package:backup_brain/features/auth/data/firebase_auth_repository.dart';
import 'package:backup_brain/features/auth/domain/auth_repository.dart';
import 'package:backup_brain/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

void main() {
  group('Firebase error codes', () {
    test('map to friendly failures', () {
      expect(
        mapFirebaseAuthCode('invalid-credential'),
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

  group('AccountInfo', () {
    test('first name for the greeting', () {
      expect(signedInAsAsad.firstName, 'Asad');
      expect(
        const AccountInfo(uid: 'x', kind: AccountKind.email).firstName,
        isNull,
      );
    });
  });

  group('AuthController', () {
    test('success clears state; cancel is silent; failure is kept', () async {
      final auth = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);
      final controller = container.read(authControllerProvider.notifier);

      expect(await controller.continueWithGoogle(), isTrue);
      expect(container.read(authControllerProvider).failure, isNull);

      auth.failWith = AuthFailureCode.cancelled;
      expect(await controller.continueWithGoogle(), isFalse);
      expect(container.read(authControllerProvider).failure, isNull);

      auth.failWith = AuthFailureCode.network;
      expect(await controller.continueWithGoogle(), isFalse);
      expect(
        container.read(authControllerProvider).failure,
        AuthFailureCode.network,
      );
    });
  });

  group('sign-up screen', () {
    testWidgets('validates before calling Firebase', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(
        tester,
        auth: auth,
        system: FakeSystemRepository(),
        appliances: FakeApplianceRepository(),
      );
      await goToSignUp(tester);
      await tester.enterText(field('Enter your email'), 'not-an-email');
      await tester.enterText(field('Enter your password'), '123');
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 6 characters.'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('a taken email shows a friendly, actionable message', (
      tester,
    ) async {
      final auth = FakeAuthRepository(failWith: AuthFailureCode.emailInUse);
      await pumpApp(
        tester,
        auth: auth,
        system: FakeSystemRepository(),
        appliances: FakeApplianceRepository(),
      );
      await goToSignUp(tester);
      await tester.enterText(field('Enter your name'), 'Asad');
      await tester.enterText(field('Enter your email'), 'asad@example.pk');
      await tester.enterText(field('Enter your password'), 'secret12');
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(
        find.text('This email already has an account. Sign in instead.'),
        findsOneWidget,
      );
    });
  });

  group('login screen', () {
    testWidgets('forgot password sends a reset link', (tester) async {
      final auth = FakeAuthRepository();
      await pumpApp(
        tester,
        auth: auth,
        system: FakeSystemRepository(),
        appliances: FakeApplianceRepository(),
      );
      await goToSignUp(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Enter your email'), 'asad@example.pk');
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(auth.calls, ['reset asad@example.pk']);
      expect(
        find.text('We sent a password reset link to asad@example.pk.'),
        findsOneWidget,
      );
    });
  });
}
