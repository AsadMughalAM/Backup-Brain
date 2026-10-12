import 'package:backup_brain/core/services/external_links.dart';
import 'package:backup_brain/features/backup/data/models/system_dto.dart';
import 'package:backup_brain/features/backup/domain/entities/household_system.dart';
import 'package:backup_brain/features/battery/domain/nearby_shops_repository.dart';
import 'package:bb_ui/bb_ui.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<FakeExternalLinks> _openHelp(
  WidgetTester tester, {
  FakeNearbyShopsRepository? shops,
  HouseholdSystem? system,
}) async {
  final links = FakeExternalLinks();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(system ?? demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
    extra: [
      externalLinksProvider.overrideWithValue(links),
      if (shops != null) nearbyShopsRepositoryProvider.overrideWithValue(shops),
    ],
  );
  await tester.tap(
    find.descendant(of: find.byType(BbNavBar), matching: find.text('Battery')),
  );
  await tester.pumpAndSettle();
  final open = find.text('Battery problem? Get help');
  await _reveal(tester, open);
  await tester.tap(open);
  await tester.pumpAndSettle();
  return links;
}

void main() {
  testWidgets('a swollen battery gets only the fixed safety text', (
    tester,
  ) async {
    await _openHelp(tester);
    await tester.tap(find.text('Swollen or bulging'));
    await tester.pumpAndSettle();
    expect(find.text('Disconnect the battery now'), findsOneWidget);

    await tester.tap(find.text('Swollen or bulging'));
    await tester.tap(find.text('Won\'t charge fully'));
    await tester.pumpAndSettle();
    expect(find.text('Disconnect the battery now'), findsNothing);
    expect(find.text('Worth a repair shop\'s check'), findsOneWidget);
  });

  testWidgets('lithium ranks cheapest over its life for the demo bank', (
    tester,
  ) async {
    await _openHelp(tester);
    await _reveal(tester, find.text('Cheapest over its life'));
    // The demo bank is 3.6 kWh; lithium at 45–65k per kWh.
    expect(find.text('Rs 1,62,000–2,34,000'), findsOneWidget);
  });

  testWidgets('"Battery shops" opens a Google Maps search in the home city', (
    tester,
  ) async {
    final links = await _openHelp(tester);
    await _reveal(tester, find.text('Battery shops'));
    await tester.tap(find.text('Battery shops'));
    await tester.pumpAndSettle();
    expect(links.searches, ['battery shop Lahore']);
  });

  testWidgets('online prices: Daraz search for a tubular battery', (
    tester,
  ) async {
    final links = await _openHelp(tester);
    await _reveal(tester, find.text("Check today's prices online"));
    await tester.tap(find.text('Tubular battery'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Daraz'));
    await tester.tap(find.text('Daraz'));
    await tester.pumpAndSettle();
    expect(links.priceSearches, [(PriceSite.daraz, '200Ah tubular battery')]);
  });

  group('with a map key (live shops)', () {
    final lahoreShops = [
      const NearbyShop(
        name: 'Rehan Battery Center',
        address: 'Hall Road, Lahore',
        site: SiteLocation(lat: 31.57, lon: 74.31),
        distanceMeters: 850,
      ),
      const NearbyShop(
        name: 'Malik Battery Agency',
        address: '',
        site: SiteLocation(lat: 31.55, lon: 74.33),
        distanceMeters: 2400,
      ),
    ];

    testWidgets('shops show on opening; one tap gives directions', (
      tester,
    ) async {
      // Battery tab → "Get help" → Directions: three taps, no typing.
      final shops = FakeNearbyShopsRepository(lahoreShops);
      final links = await _openHelp(tester, shops: shops);

      expect(shops.searched, [ShopKind.battery]);
      await _reveal(tester, find.text('Rehan Battery Center'));
      expect(find.text('850 m · Hall Road, Lahore'), findsOneWidget);
      expect(find.text('2.4 km'), findsOneWidget);

      await tester.tap(find.text('Directions').first);
      await tester.pumpAndSettle();
      expect(links.directions, [(31.57, 74.31)]);
    });

    testWidgets("won't charge suggests UPS and inverter repair", (
      tester,
    ) async {
      final shops = FakeNearbyShopsRepository(lahoreShops);
      await _openHelp(tester, shops: shops);
      await tester.tap(find.text("Won't charge fully"));
      await tester.pumpAndSettle();
      expect(shops.searched, [ShopKind.battery, ShopKind.upsRepair]);

      // The user's own choice wins over the suggestion.
      await _reveal(tester, find.text('Solar installers'));
      await tester.tap(find.text('Solar installers'));
      await tester.pumpAndSettle();
      expect(shops.searched.last, ShopKind.solarInstaller);
    });

    testWidgets('offline: Try again, and Google Maps still works', (
      tester,
    ) async {
      final shops = FakeNearbyShopsRepository(lahoreShops)..offline = true;
      final links = await _openHelp(tester, shops: shops);
      await _reveal(tester, find.text("Couldn't load shops"));

      await tester.tap(find.text('More on Google Maps'));
      await tester.pumpAndSettle();
      expect(links.searches, ['battery shop Lahore']);

      shops.offline = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Rehan Battery Center'), findsOneWidget);
    });

    testWidgets('no Maps app: says so instead of doing nothing', (
      tester,
    ) async {
      final links = await _openHelp(
        tester,
        shops: FakeNearbyShopsRepository(lahoreShops),
      );
      links.canOpen = false;
      await _reveal(tester, find.text('Directions').first);
      await tester.tap(find.text('Directions').first);
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't open Google Maps"), findsOneWidget);
    });

    testWidgets('searches around the home area, e.g. Johar Town', (
      tester,
    ) async {
      final raw = demoJson()['system'] as Map<String, dynamic>;
      final inJoharTown = SystemDto.fromMap({
        ...raw,
        'location': <String, dynamic>{
          ...raw['location'] as Map<String, dynamic>,
          'area': 'Johar Town',
        },
      });
      final shops = FakeNearbyShopsRepository(lahoreShops);
      final links = await _openHelp(tester, shops: shops, system: inJoharTown);

      expect(shops.areas, ['Johar Town']);
      expect(find.textContaining('near Johar Town, Lahore'), findsOneWidget);
      await _reveal(tester, find.text('More on Google Maps'));
      await tester.tap(find.text('More on Google Maps'));
      await tester.pumpAndSettle();
      expect(links.searches, ['battery shop Johar Town Lahore']);
    });
  });
}
