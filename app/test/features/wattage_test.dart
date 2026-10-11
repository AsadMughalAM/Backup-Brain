import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

Future<FakeApplianceRepository> _openLoads(WidgetTester tester) async {
  final appliances = FakeApplianceRepository(demoAppliances());
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: appliances,
  );
  await tester.tap(find.text('Loads'));
  await tester.pumpAndSettle();
  return appliances;
}

Future<void> _openWatts(WidgetTester tester, String label) async {
  final button = find.bySemanticsLabel(label);
  await tester.scrollUntilVisible(
    button,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  // Built isn't on screen: it may sit under the nav bar.
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('one tap on the kind of fan fixes its watts and the backup '
      'time', (tester) async {
    final handle = tester.ensureSemantics();
    final appliances = await _openLoads(tester);
    // Demo: 420 W from 60% → 3h 28m.
    expect(find.text('3h 28m'), findsOneWidget);

    await _openWatts(tester, 'Change watts: Ceiling fan (bedroom), 75 W');
    expect(find.text('Which Ceiling fan (bedroom)?'), findsOneWidget);
    // The current kind is marked.
    expect(find.text('Normal fan · 75 W'), findsOneWidget);
    await tester.tap(find.text('Inverter / DC fan · 35 W'));
    await tester.pumpAndSettle();

    expect(find.text('Which Ceiling fan (bedroom)?'), findsNothing);
    final fan = (await appliances.watchAll().first).firstWhere(
      (a) => a.id == 'fan-bedroom',
    );
    expect(fan.watts, 35);
    // 380 W: (0.6 − 0.15) × 3240 / 380 = 3.84 h.
    expect(find.text('3h 50m'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the exact number off the sticker: ±5 W, then Done', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final appliances = await _openLoads(tester);
    await _openWatts(tester, 'Change watts: Wi-Fi router, 10 W');
    await tester.tap(find.byTooltip('5 W more'));
    await tester.tap(find.byTooltip('5 W more'));
    await tester.pumpAndSettle();
    expect(find.text('20 W'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final router = (await appliances.watchAll().first).firstWhere(
      (a) => a.id == 'router',
    );
    expect(router.watts, 20);
    handle.dispose();
  });

  testWidgets('closing without choosing changes nothing', (tester) async {
    final handle = tester.ensureSemantics();
    final appliances = await _openLoads(tester);
    await _openWatts(tester, 'Change watts: Wi-Fi router, 10 W');
    await tester.tap(find.byTooltip('5 W more'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();
    final router = (await appliances.watchAll().first).firstWhere(
      (a) => a.id == 'router',
    );
    expect(router.watts, 10);
    handle.dispose();
  });
}
