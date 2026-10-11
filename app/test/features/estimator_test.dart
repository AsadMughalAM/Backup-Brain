import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

Future<void> _openEstimator(WidgetTester tester) async {
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
  );
  await tester.tap(find.text('Solar'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Solar cost estimator'));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) => tester
    .scrollUntilVisible(finder, 300, scrollable: find.byType(Scrollable).first);

void main() {
  testWidgets('400 units in Lahore: three packages, Hybrid recommended '
      '(ARCHITECTURE §12 step 5)', (tester) async {
    await _openEstimator(tester);

    await tester.enterText(find.byType(EditableText).first, '400');
    await tester.pumpAndSettle();

    // 400 / (30 × 5.1 × 0.78) = 3.35 kWp → 6 × 580 W.
    await _reveal(tester, find.text('Basic'));
    expect(find.text('6 × 580 W panels (3.5 kW)'), findsWidgets);
    // 28 × 3480 + 1,20,000 + 18,000 × 3.48 = 2,80,080 → Rs 2,80,000.
    expect(find.text('Rs 2,80,000–4,00,000'), findsOneWidget);
    expect(find.text('Saves about Rs 22,000 a month'), findsWidgets);

    await _reveal(tester, find.text('Recommended'));
    // 420 W (the home's load) × 4 h / (0.85 × 0.9) = 2.2 kWh → 2.5 kWh.
    expect(
      find.text('2.5 kWh lithium battery: about 4h 0m at 420 W'),
      findsOneWidget,
    );
    await _reveal(tester, find.text('Questions to ask your installer'));
    await _reveal(
      tester,
      find.textContaining('Prices last updated 2026-10-11'),
    );
    expect(find.textContaining('sample prices'), findsOneWidget);
  });

  testWidgets('a bill in rupees is turned into units at the tariff', (
    tester,
  ) async {
    await _openEstimator(tester);
    await tester.tap(find.text('Bill (Rs)'));
    await tester.pumpAndSettle();
    expect(find.text('Converted at Rs 55 per unit.'), findsOneWidget);
    // Rs 22,000 / 55 = 400 units: the same packages as above.
    await tester.enterText(find.byType(EditableText).first, '22000');
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('Rs 2,80,000–4,00,000'));
  });
}
