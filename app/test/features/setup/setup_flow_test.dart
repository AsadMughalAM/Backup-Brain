import 'package:backup_brain/core/widgets/brand_logo.dart';
import 'package:bb_ui/bb_ui.dart';
import 'package:backup_brain/features/setup/data/models/setup_draft_dto.dart';
import 'package:backup_brain/features/setup/domain/home_locator.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.scrollUntilVisible(target, 200, scrollable: pageScroll);
  // Built isn't on screen: it may sit under the sticky bottom bar.
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

/// Karachi, no solar, tubular, the usual appliances minus one fan.
Future<void> _setUpKarachiHome(WidgetTester tester) async {
  await pickCity(tester, 'Karachi');
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

/// "Use my location" answers with [place], or fails with [failure].
class _FakeLocator implements HomeLocator {
  _FakeLocator({this.place, this.failure});

  final FoundPlace? place;
  final LocateFailure? failure;
  final settingsOpened = <LocateFailure>[];

  @override
  Future<FoundPlace> locate() async {
    final failure = this.failure;
    if (failure != null) throw LocateException(failure);
    return place!;
  }

  @override
  Future<void> openSettings(LocateFailure failure) async =>
      settingsOpened.add(failure);
}

const _gulberg = FoundPlace(
  site: SiteLocation(lat: 31.5161, lon: 74.3428),
  city: 'Lahore',
  area: 'Gulberg III',
  country: 'Pakistan',
);

Future<FakeSystemRepository> _pumpSetup(
  WidgetTester tester, {
  HomeLocator? locator,
  FakeApplianceRepository? appliances,
}) async {
  final system = FakeSystemRepository();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(),
    system: system,
    appliances: appliances ?? FakeApplianceRepository(),
    extra: [
      if (locator != null) homeLocatorProvider.overrideWithValue(locator),
    ],
  );
  return system;
}

/// The input of the field labelled [label] (shown above the input).
Finder _labelled(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(BbTextField)),
  matching: find.byType(EditableText),
);

String _fieldText(WidgetTester tester, String label) =>
    tester.widget<EditableText>(_labelled(label)).controller.text;

Future<void> _type(WidgetTester tester, Finder target, String text) async {
  await tester.enterText(target, text);
  await tester.pumpAndSettle();
}

/// The sheet's own copy of [text] (the page may show it too).
Finder _inSheet(String text) =>
    find.descendant(of: find.byType(BottomSheet), matching: find.text(text));

Future<void> _tapInSheet(WidgetTester tester, String text) async {
  await tester.ensureVisible(_inSheet(text));
  await tester.pumpAndSettle();
  await tester.tap(_inSheet(text));
  await tester.pumpAndSettle();
}

/// Karachi, no solar, tubular: on to the appliances.
Future<void> _toAppliances(WidgetTester tester) async {
  await pickCity(tester, 'Karachi');
  await _tap(tester, 'No, just UPS and battery');
  await _next(tester);
  await _tap(tester, 'Tubular battery');
  await _next(tester);
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
    expect(find.byType(BrandLogo), findsOneWidget);
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
    await pickCity(tester, 'Multan');
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
    await pickCity(tester, 'Lahore');
    expect(find.text('How many panels?'), findsNothing);
    await _tap(tester, 'Yes, I have solar');
    // 6 × 550 W pre-picked.
    expect(find.text('3.3 kW of panels in total'), findsOneWidget);
    await tester.tap(find.byTooltip('More').first); // a 7th panel
    await tester.pumpAndSettle();
    expect(find.text('3.9 kW of panels in total'), findsOneWidget);
    // Shade: one optional tap, none pre-picked as the usual answer.
    expect(find.text('Any shade on the panels in the day?'), findsOneWidget);
    await _tap(tester, 'Some');
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
    expect(saved.solar!.shading, PanelShading.partial);
    expect(saved.location!.city, 'Lahore');
    // "How full is it now?" was answered: the live estimate starts there.
    expect(saved.socAt, isNotNull);
    expect(saved.socCheckedAt, saved.socAt);
  });

  group('home location', () {
    testWidgets('"Use my location" fills city and area; the forecast uses the '
        "phone's own point", (tester) async {
      final system = await _pumpSetup(
        tester,
        locator: _FakeLocator(place: _gulberg),
      );
      await _tap(tester, 'Use my location');
      expect(
        find.text('Found: Gulberg III, Lahore, Pakistan. Check it below.'),
        findsOneWidget,
      );
      expect(find.text('Lahore'), findsOneWidget); // the city field
      expect(_fieldText(tester, 'Area (optional)'), 'Gulberg III');

      await _tap(tester, 'No, just UPS and battery');
      await _next(tester);
      await _tap(tester, 'Tubular battery');
      await _next(tester);
      await tester.tap(find.text('Show my backup time'));
      await tester.pumpAndSettle();
      await _signUp(tester);

      final home = (await system.watch().first)!.location!;
      expect(home.city, 'Lahore');
      expect(home.area, 'Gulberg III');
      expect(home.site.lat, 31.5161);
    });

    testWidgets("a town that isn't listed gets the nearest listed city", (
      tester,
    ) async {
      await _pumpSetup(
        tester,
        locator: _FakeLocator(
          place: const FoundPlace(
            site: SiteLocation(lat: 31.02, lon: 73.85),
            city: 'Pattoki',
          ),
        ),
      );
      await _tap(tester, 'Use my location');
      expect(
        find.textContaining("Pattoki isn't on our list, so we picked Okara"),
        findsOneWidget,
      );
    });

    testWidgets(
      'location not allowed: says so; the city can still be picked and '
      'the area typed',
      (tester) async {
        final locator = _FakeLocator(failure: LocateFailure.blocked);
        await _pumpSetup(tester, locator: locator);
        await _tap(tester, 'Use my location');
        expect(
          find.textContaining('Location is blocked for this app'),
          findsOneWidget,
        );
        await _tap(tester, 'Open settings');
        expect(locator.settingsOpened, [LocateFailure.blocked]);

        await pickCity(tester, 'Rahim Yar Khan');
        expect(find.text('Rahim Yar Khan'), findsOneWidget);
        await _type(tester, _labelled('Area (optional)'), 'Model Town');
        // Kept on the phone like every other answer.
        final draft = (await savedOnPhone())['setupDraft'] as String;
        expect(draft, contains('"area":"Model Town"'));
        expect(draft, contains('"cityId":"rahim-yar-khan"'));
      },
    );
  });

  testWidgets('"Other" takes a panel size off the sticker, within reason', (
    tester,
  ) async {
    await _pumpSetup(tester);
    await pickCity(tester, 'Lahore');
    await _tap(tester, 'Yes, I have solar');
    await _tap(tester, 'Other');

    final sheetField = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(EditableText),
    );
    await _type(tester, sheetField, '6000');
    await _tapInSheet(tester, 'Done');
    expect(find.text('Enter a number from 50 to 1000 W.'), findsOneWidget);

    await _type(tester, sheetField, '600');
    await _tapInSheet(tester, 'Done');
    // 6 × 600 W, and the typed size is now its own picked chip.
    expect(find.text('600 W'), findsOneWidget);
    expect(find.text('3.6 kW of panels in total'), findsOneWidget);
  });

  testWidgets(
    'an appliance the list lacks: picked by kind, counted in the backup and '
    'saved with the home',
    (tester) async {
      final appliances = FakeApplianceRepository();
      await _pumpSetup(tester, appliances: appliances);
      await _toAppliances(tester);
      expect(find.text('backup at 370 W'), findsOneWidget);

      await _tap(tester, 'Add an appliance');
      await _tapInSheet(tester, 'LED bulb');
      await _tapInSheet(tester, 'Tube light · 40 W');
      expect(_fieldText(tester, 'Name'), 'Tube light');
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byTooltip('More'),
        ),
      );
      await tester.pumpAndSettle();
      await _tapInSheet(tester, 'Add');

      // 2 × 40 W more on backup.
      expect(find.text('Tube light'), findsOneWidget);
      expect(find.text('backup at 450 W'), findsOneWidget);
      await tester.tap(find.text('Show my backup time'));
      await tester.pumpAndSettle();
      await _signUp(tester);

      final saved = await appliances.watchAll().first;
      final tube = saved.singleWhere((a) => a.name == 'Tube light');
      expect((tube.watts, tube.quantity, tube.iconKey), (40.0, 2, 'light'));
      expect(tube.isOn, isTrue);
    },
  );

  testWidgets('an added appliance needs a name, and can be removed again', (
    tester,
  ) async {
    await _pumpSetup(tester);
    await _toAppliances(tester);
    await _tap(tester, 'Add an appliance');
    // Nothing typed: it says what is missing instead of adding a blank.
    await _tapInSheet(tester, 'Add');
    expect(find.text('Give it a name.'), findsOneWidget);

    await _type(tester, _labelled('Name'), 'Aquarium pump');
    await _type(tester, _labelled('Watts, each'), '25');
    await _tapInSheet(tester, 'Add');
    expect(find.text('Aquarium pump'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Aquarium pump'));
    await tester.pumpAndSettle();
    expect(find.text('Aquarium pump'), findsNothing);
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
        'area': 'Gulberg III',
        'site': {'lat': 31.5, 'lon': 74.3},
        'customAppliances': [
          {
            'id': 'custom-1',
            'name': 'Tube light',
            'icon': 'light',
            'watts': 40,
            'quantity': 2,
            'heavy': false,
          },
        ],
        'hasSolar': false,
        'step': 2,
        'finished': false,
      }),
    );
    expect(json['chemistry'], 'tubular');
    expect(json['step'], 2);
    expect(json['quantities'], {'fan': 3});
    expect(json['area'], 'Gulberg III');
    expect(json['site'], {'lat': 31.5, 'lon': 74.3});
    expect(
      (json['customAppliances'] as List).single,
      containsPair('watts', 40.0),
    );
  });

  test('a draft saved before areas and added appliances still reads', () {
    final draft = SetupDraftDto.fromJson({
      'panelCount': 6,
      'panelWatts': 550,
      'batteryCount': 1,
      'soc': 1,
      'quantities': <String, dynamic>{},
    });
    expect(draft.area, isNull);
    expect(draft.site, isNull);
    expect(draft.customAppliances, isEmpty);
  });
}
