import 'package:backup_brain/features/setup/data/models/setup_draft_dto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

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

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

/// Karachi, no solar, tubular, the usual appliances minus one fan.
Future<void> _setUpKarachiHome(WidgetTester tester) async {
  await _tap(tester, 'Karachi');
  await _tap(tester, 'No, just UPS and battery');
  await _next(tester);
  await _tap(tester, 'Tubular battery');
  // 12 V × 200 Ah tubular, full, on a 1000 W UPS, with the usual 370 W of
  // fans, lights, fridge, TV and router on.
  expect(find.text('Your backup: about 2h 45m'), findsOneWidget);
  expect(find.text('backup at 370 W'), findsOneWidget);
  await _next(tester);
  expect(find.text('What runs during load-shedding?'), findsOneWidget);
  await tester.tap(find.byTooltip('Fewer').first); // one fan fewer
  await tester.pumpAndSettle();
  expect(find.text('backup at 295 W'), findsOneWidget);
  await tester.tap(find.text('Show my backup time'));
  await tester.pumpAndSettle();
}

Future<void> _signUp(WidgetTester tester) async {
  await tester.enterText(field('Enter your name'), 'Sana');
  await tester.enterText(field('Enter your email'), 'sana@example.pk');
  await tester.enterText(field('Enter your password'), 'secret12');
  await tester.tap(find.text('Sign up'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first open: setup, then sign-up saves it to the account', (
    tester,
  ) async {
    final system = FakeSystemRepository();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: system,
      appliances: FakeApplianceRepository(),
    );
    expect(find.text('Where is your home?'), findsOneWidget);
    await _setUpKarachiHome(tester);

    // The account comes after the payoff, and the payoff is repeated there.
    expect(find.text('Join for a smarter backup.'), findsOneWidget);
    expect(find.text('Your home is ready'), findsOneWidget);
    expect(
      find.text(
        'Backup about 3h 27m. Create an account to keep it safe, on any phone.',
      ),
      findsOneWidget,
    );

    await _signUp(tester);
    expect(find.text('Assalam-o-alaikum, Sana'), findsOneWidget);
    expect(find.text('3h 27m'), findsOneWidget);
    expect(system.demoLoads, 0);
    final saved = await system.watch().first;
    expect(saved!.location!.city, 'Karachi');
    expect(saved.battery.nominalWh, 2400);
    // Now in the account: the phone's copy is gone.
    expect((await savedOnPhone()).containsKey('setupDraft'), isFalse);
  });

  testWidgets('leaving mid-setup: the app reopens on the same step', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: FakeSystemRepository(),
      appliances: FakeApplianceRepository(),
    );
    await _tap(tester, 'Multan');
    await _tap(tester, 'No, just UPS and battery');
    await _next(tester);
    await _tap(tester, 'Lithium battery');

    // Close the app and open it again with what the phone saved.
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: FakeSystemRepository(),
      appliances: FakeApplianceRepository(),
      saved: await savedOnPhone(),
    );
    expect(find.text('What battery do you have?'), findsOneWidget);
    // Lithium is still picked, so its sizes are showing.
    expect(find.text('Pack voltage'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    // Step 1 still answered: Next goes straight on.
    await _next(tester);
    expect(find.text('What battery do you have?'), findsOneWidget);
  });

  testWidgets('finished setup but no account yet: reopens on sign-up', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: FakeSystemRepository(),
      appliances: FakeApplianceRepository(),
    );
    await _setUpKarachiHome(tester);
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: FakeSystemRepository(),
      appliances: FakeApplianceRepository(),
      saved: await savedOnPhone(),
    );
    expect(find.text('Your home is ready'), findsOneWidget);
  });

  testWidgets('logging into an account that has a home keeps that home', (
    tester,
  ) async {
    final system = FakeSystemRepository(demoSystem());
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: system,
      appliances: FakeApplianceRepository(demoAppliances()),
    );
    await _setUpKarachiHome(tester);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Enter your email'), 'asad@example.pk');
    await tester.enterText(field('Enter your password'), 'secret12');
    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();

    // The account's own household (demo numbers), not this phone's answers.
    expect(find.text('3h 28m'), findsOneWidget);
    expect((await savedOnPhone()).containsKey('setupDraft'), isFalse);
  });

  testWidgets('solar home: panel questions appear only after "Yes"', (
    tester,
  ) async {
    final system = FakeSystemRepository();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: system,
      appliances: FakeApplianceRepository(),
    );
    await _tap(tester, 'Lahore');
    expect(find.text('How many panels?'), findsNothing);
    await _tap(tester, 'Yes, I have solar');
    // 6 × 550 W pre-picked.
    expect(find.text('3.3 kW of panels in total'), findsOneWidget);
    await tester.tap(find.byTooltip('More').first); // a 7th panel
    await tester.pumpAndSettle();
    expect(find.text('3.9 kW of panels in total'), findsOneWidget);
    await _next(tester);
    await _tap(tester, 'Lithium battery');
    // Solar homes are asked about the inverter, not a UPS.
    expect(find.text('Inverter size'), findsOneWidget);
    await _next(tester);
    await tester.tap(find.text('Show my backup time'));
    await tester.pumpAndSettle();
    await _signUp(tester);

    final saved = await system.watch().first;
    expect(saved!.solar!.kWp, closeTo(3.85, 1e-9));
    expect(saved.location!.city, 'Lahore');
  });

  test('the saved draft round-trips through JSON', () {
    final json = SetupDraftDto.toJson(
      SetupDraftDto.fromJson({
        'panelCount': 6,
        'panelWatts': 550,
        'batteryCount': 2,
        'soc': 0.75,
        'quantities': {'fan': 3},
        'chemistry': 'tubular',
        'cityId': 'lahore',
        'hasSolar': false,
        'step': 2,
        'finished': false,
      }),
    );
    expect(json['chemistry'], 'tubular');
    expect(json['step'], 2);
    expect(json['quantities'], {'fan': 3});
  });
}
