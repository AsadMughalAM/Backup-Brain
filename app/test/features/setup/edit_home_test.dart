import 'package:backup_brain/core/widgets/brand_logo.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

/// Taps the first [text], scrolled fully into view (the sticky bottom bar
/// can cover a half-visible one).
Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.scrollUntilVisible(target, 200, scrollable: pageScroll);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Settings → Edit my home: starts filled in, saves over it', (
    tester,
  ) async {
    // The battery was read an hour ago and the panels washed last week:
    // setup doesn't ask either, so an edit must keep both.
    final readAt = DateTime.utc(2026, 10, 11, 9);
    final cleanedAt = DateTime.utc(2026, 10, 4);
    final demo = demoSystem();
    final system = FakeSystemRepository(
      demo.copyWith(
        socAt: readAt,
        socCheckedAt: readAt,
        solar: SolarSpec(kWp: demo.solar!.kWp, lastCleanedAt: cleanedAt),
      ),
    );
    final appliances = FakeApplianceRepository(demoAppliances());
    await pumpApp(
      tester,
      auth: FakeAuthRepository(account: signedInAsAsad),
      system: system,
      appliances: appliances,
    );
    // Switched off in the planner before editing; must stay off.
    await appliances.setOn('tv', isOn: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Lahore · 24 V 150 Ah · 2.2 kW solar'), findsOneWidget);
    await _tap(tester, 'Edit my home');

    // Everything already answered: no Login, no demo link, Next is live.
    expect(find.text('Edit my home'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
    expect(find.text('2.2 kW of panels in total'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // A bigger battery.
    await _tap(tester, '200 Ah');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final saved = await system.watch().first;
    expect(saved!.battery.ampHours, 200);
    expect(saved.battery.chemistry.name, 'lifepo4');
    expect(saved.panels!.count, 4);
    expect(saved.socAt, readAt);
    expect(saved.socCheckedAt, readAt);
    expect(saved.solar!.lastCleanedAt, cleanedAt);

    final list = await appliances.watchAll().first;
    // The demo's two fans became one "Ceiling fan × 2" entry…
    expect(list.where((a) => a.iconKey == 'fan').single.quantity, 2);
    // …and the TV kept its "off" from the planner.
    expect(list.firstWhere((a) => a.iconKey == 'tv').isOn, isFalse);
    // Back on Home with the new numbers.
    expect(find.byType(BrandLogo), findsOneWidget);
  });

  testWidgets('"Where is this written?" shows the sticker line to read', (
    tester,
  ) async {
    await pumpApp(
      tester,
      auth: FakeAuthRepository(),
      system: FakeSystemRepository(),
      appliances: FakeApplianceRepository(),
    );
    await pickCity(tester, 'Karachi');
    await _tap(tester, 'No, just UPS and battery');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await _tap(tester, 'Tubular battery');

    expect(find.text('12V 200Ah'), findsNothing);
    await _tap(tester, 'Where is this written?');
    expect(find.text('12V 200Ah'), findsOneWidget);
    await _tap(tester, 'Hide the example');
    expect(find.text('12V 200Ah'), findsNothing);
  });
}
