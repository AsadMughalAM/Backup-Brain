import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

/// Signs a brand-new account up, which lands on setup.
Future<void> _signUpNewAccount(
  WidgetTester tester,
  FakeSystemRepository system,
  FakeApplianceRepository appliances,
) async {
  await pumpApp(
    tester,
    auth: FakeAuthRepository(),
    system: system,
    appliances: appliances,
  );
  await goToSignUp(tester);
  await tester.enterText(field('Enter your name'), 'Sana');
  await tester.enterText(field('Enter your email'), 'sana@example.pk');
  await tester.enterText(field('Enter your password'), 'secret12');
  await tester.tap(find.text('Sign up'));
  await tester.pumpAndSettle();
  expect(find.text('Where is your home?'), findsOneWidget);
}

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no solar, tubular: three steps to a real countdown', (
    tester,
  ) async {
    final system = FakeSystemRepository();
    final appliances = FakeApplianceRepository();
    await _signUpNewAccount(tester, system, appliances);

    // Step 1: two taps. Next stays off until both are answered.
    await _tap(tester, 'Karachi');
    await _tap(tester, 'No, just UPS and battery');
    expect(find.text('How many panels?'), findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: one tap; the usual sizes are already picked.
    expect(find.text('What battery do you have?'), findsOneWidget);
    await _tap(tester, 'Tubular battery');
    // 12 V × 200 Ah tubular, full, on a 1000 W UPS, with the usual 370 W of
    // fans, lights, fridge, TV and router on.
    expect(find.text('Your backup: about 2h 45m'), findsOneWidget);
    expect(find.text('backup at 370 W'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: adjusting a number updates the backup time live.
    expect(find.text('What runs during load-shedding?'), findsOneWidget);
    await tester.tap(find.byTooltip('Fewer').first); // one fan fewer
    await tester.pumpAndSettle();
    expect(find.text('backup at 295 W'), findsOneWidget);

    await tester.tap(find.text('Show my backup time'));
    await tester.pumpAndSettle();

    // Saved and on Home with their own numbers, not the demo's.
    expect(system.demoLoads, 0);
    expect(find.text('Assalam-o-alaikum, Sana'), findsOneWidget);
    expect(find.text('3h 27m'), findsOneWidget);
    final saved = await system.watch().first;
    expect(saved!.hasSolar, isFalse);
    expect(saved.location!.city, 'Karachi');
    expect(saved.battery.nominalWh, 2400);
  });

  testWidgets('solar home: panel questions appear only after "Yes"', (
    tester,
  ) async {
    final system = FakeSystemRepository();
    await _signUpNewAccount(tester, system, FakeApplianceRepository());

    await _tap(tester, 'Lahore');
    await _tap(tester, 'Yes, I have solar');
    // 6 × 550 W pre-picked.
    expect(find.text('3.3 kW of panels in total'), findsOneWidget);
    await tester.tap(find.byTooltip('More').first); // a 7th panel
    await tester.pumpAndSettle();
    expect(find.text('3.9 kW of panels in total'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await _tap(tester, 'Lithium battery');
    // Solar homes are asked about the inverter, not a UPS.
    expect(find.text('Inverter size'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show my backup time'));
    await tester.pumpAndSettle();

    final saved = await system.watch().first;
    expect(saved!.solar!.kWp, closeTo(3.85, 1e-9));
    expect(saved.location!.city, 'Lahore');
  });

  testWidgets('Back keeps every answer', (tester) async {
    await _signUpNewAccount(
      tester,
      FakeSystemRepository(),
      FakeApplianceRepository(),
    );
    await _tap(tester, 'Multan');
    await _tap(tester, 'No, just UPS and battery');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    // Still answered: Next is enabled straight away.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('What battery do you have?'), findsOneWidget);
  });
}
