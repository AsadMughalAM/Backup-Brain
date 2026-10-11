import 'package:bb_ui/bb_ui.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// A finished 1h 30m outage at 420 W from 90%, [daysAgo] days back. With
/// [capacityWh] set, the user entered the % a battery of that size would
/// show: 420 × 1.5 / 0.9 / capacity below the start.
OutageEvent _outage(int daysAgo, {double? capacityWh}) {
  final start = DateTime(2026, 10, 11 - daysAgo, 19);
  return OutageEvent(
    id: 'o$daysAgo',
    startedAt: start,
    endedAt: start.add(const Duration(minutes: 90)),
    startSoc: 0.9,
    avgLoadW: 420,
    endSoc: capacityWh == null ? 0.72 : 0.9 - 420 * 1.5 / 0.9 / capacityWh,
    endSocMeasured: capacityWh != null,
  );
}

Future<FakeOutageRepository> _openBattery(
  WidgetTester tester,
  List<OutageEvent> history,
) async {
  final outages = FakeOutageRepository(outages: history);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
    outages: outages,
  );
  await tester.tap(
    find.descendant(of: find.byType(BbNavBar), matching: find.text('Battery')),
  );
  await tester.pumpAndSettle();
  return outages;
}

void main() {
  testWidgets('no readings yet: explains how to get a health check', (
    tester,
  ) async {
    await _openBattery(tester, const []);
    expect(find.text('No health check yet'), findsOneWidget);
    expect(find.text('0 of 3 readings'), findsOneWidget);
  });

  testWidgets('entering the % after an outage records a measured reading', (
    tester,
  ) async {
    final outages = await _openBattery(tester, [_outage(1)]);
    await tester.tap(find.text('Enter %'));
    await tester.pumpAndSettle();
    // Starts at the estimate (72% → 70%); one step down = 65%.
    expect(find.text('70%'), findsOneWidget);
    await tester.tap(find.byTooltip('5% less'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = outages.outages.single;
    expect(saved.endSocMeasured, isTrue);
    expect(saved.endSoc, closeTo(0.65, 1e-9));
    expect(find.text('1 of 3 readings'), findsOneWidget);
  });

  testWidgets('three readings of a 2.7 kWh battery: 75%, wearing, warning', (
    tester,
  ) async {
    await _openBattery(tester, [
      for (var d = 1; d <= 3; d++) _outage(d, capacityWh: 2700),
    ]);
    expect(find.text('75'), findsOneWidget);
    expect(find.text('Wearing out'), findsOneWidget);
    expect(
      find.text('Holds about 2.7 kWh of its 3.6 kWh label.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Battery holds less than before'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  });
}
