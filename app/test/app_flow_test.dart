import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/fakes.dart';

void main() {
  group('signed in', () {
    testWidgets('dashboard shows the §12 hook number and greets by name', (
      tester,
    ) async {
      await pumpApp(
        tester,
        auth: FakeAuthRepository(account: signedInAsAsad),
        system: FakeSystemRepository(demoSystem()),
        appliances: FakeApplianceRepository(demoAppliances()),
      );
      expect(find.text('Assalam-o-alaikum, Asad'), findsOneWidget);
      expect(find.text('3h 28m'), findsOneWidget);
      expect(find.text('left at 420 W'), findsOneWidget);
      expect(find.textContaining('Turn off LED TV'), findsOneWidget);
    });

    testWidgets('load planner: TV and fridge off gives 5h 49m', (tester) async {
      final appliances = FakeApplianceRepository(demoAppliances());
      await pumpApp(
        tester,
        auth: FakeAuthRepository(account: signedInAsAsad),
        system: FakeSystemRepository(demoSystem()),
        appliances: appliances,
      );
      await tester.tap(find.text('What should I turn off?'));
      await tester.pumpAndSettle();
      await appliances.setOn('tv', isOn: false);
      await appliances.setOn('fridge', isOn: false);
      await tester.pumpAndSettle();
      expect(find.text('5h 49m'), findsOneWidget);
    });

    testWidgets('iron + water motor: overload warning (demo step 2)', (
      tester,
    ) async {
      final appliances = FakeApplianceRepository(demoAppliances());
      await pumpApp(
        tester,
        auth: FakeAuthRepository(account: signedInAsAsad),
        system: FakeSystemRepository(demoSystem()),
        appliances: appliances,
      );
      await appliances.setOn('iron', isOn: true);
      await appliances.setOn('motor', isOn: true);
      await tester.pumpAndSettle();
      expect(find.text('Overload'), findsOneWidget);
    });

    testWidgets('sign out from Settings returns to the intro', (tester) async {
      final auth = FakeAuthRepository(account: signedInAsAsad);
      await pumpApp(
        tester,
        auth: auth,
        system: FakeSystemRepository(demoSystem()),
        appliances: FakeApplianceRepository(demoAppliances()),
      );
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Signed in as Asad Ali'), findsOneWidget);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['signOut']);
      expect(find.text('Backup Brain'), findsOneWidget); // intro slide 1
    });
  });

  group('signed out', () {
    testWidgets('intro → sign up → setup, and the demo is one tap away', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final system = FakeSystemRepository();
      await pumpApp(
        tester,
        auth: auth,
        system: system,
        appliances: FakeApplianceRepository(),
      );
      expect(find.text('Backup Brain'), findsOneWidget);
      await goToSignUp(tester);
      expect(find.text('Join for a smarter backup.'), findsOneWidget);

      await tester.enterText(field('Enter your name'), 'Asad Ali');
      await tester.enterText(field('Enter your email'), 'asad@example.pk');
      await tester.enterText(field('Enter your password'), 'secret12');
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(auth.calls, ['signUp Asad Ali <asad@example.pk>']);
      // A new account sets up its own home; nothing is seeded behind its back.
      expect(find.text('Where is your home?'), findsOneWidget);
      expect(system.demoLoads, 0);

      await tester.scrollUntilVisible(
        find.text('Just looking? Try the demo home'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Just looking? Try the demo home'));
      await tester.pumpAndSettle();
      expect(system.demoLoads, 1);
      expect(find.text('3h 28m'), findsOneWidget);
      expect(find.text('Assalam-o-alaikum, Asad'), findsOneWidget);
    });

    testWidgets('Google on the login screen goes to setup for a new account', (
      tester,
    ) async {
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
      expect(find.text('Welcome back!'), findsOneWidget);

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['google']);
      expect(find.text('Where is your home?'), findsOneWidget);
    });

    testWidgets('returning user: existing household is never overwritten', (
      tester,
    ) async {
      final system = FakeSystemRepository(demoSystem().copyWith(soc: 0.8));
      await pumpApp(
        tester,
        auth: FakeAuthRepository(),
        system: system,
        appliances: FakeApplianceRepository(demoAppliances()),
      );
      await goToSignUp(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Enter your email'), 'asad@example.pk');
      await tester.enterText(field('Enter your password'), 'secret12');
      await tester.tap(find.text('Login').first);
      await tester.pumpAndSettle();

      expect(system.demoLoads, 0);
      expect(find.text('80'), findsOneWidget); // their battery, not demo 60%
    });

    testWidgets('offline right after sign-up: setup card with retry', (
      tester,
    ) async {
      final system = FakeSystemRepository()..offline = true;
      await pumpApp(
        tester,
        auth: FakeAuthRepository(),
        system: system,
        appliances: FakeApplianceRepository(),
      );
      await goToSignUp(tester);
      await tester.enterText(field('Enter your name'), 'Asad');
      await tester.enterText(field('Enter your email'), 'asad@example.pk');
      await tester.enterText(field('Enter your password'), 'secret12');
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(system.demoLoads, 0);
      expect(find.text('Setting up your home'), findsOneWidget);

      system.offline = false;
      await tester.tap(find.text('Load the demo household'));
      await tester.pumpAndSettle();
      expect(find.text('3h 28m'), findsOneWidget);
    });
  });
}
