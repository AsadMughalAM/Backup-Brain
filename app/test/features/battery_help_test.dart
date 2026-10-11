import 'package:backup_brain/core/services/external_links.dart';
import 'package:bb_ui/bb_ui.dart';
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

Future<FakeExternalLinks> _openHelp(WidgetTester tester) async {
  final links = FakeExternalLinks();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
    extra: [externalLinksProvider.overrideWithValue(links)],
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
}
