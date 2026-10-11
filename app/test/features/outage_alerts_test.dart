import 'package:bb_ui/bb_ui.dart';
import 'package:backup_brain/core/services/alert_scheduler.dart';
import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// 3 PM local on Sunday 11 Oct 2026; local, so any time zone reads the same.
final _now = DateTime(2026, 10, 11, 15);

List<OutageEvent> _eveningCuts() => [
  for (var d = 1; d <= 5; d++)
    OutageEvent(
      id: 'past$d',
      startedAt: DateTime(2026, 10, 11 - d, 19),
      endedAt: DateTime(2026, 10, 11 - d, 20, 30),
    ),
];

Future<FakeAlertScheduler> _pump(
  WidgetTester tester, {
  List<OutageEvent> history = const [],
  DateTime? now,
}) async {
  final at = now ?? _now;
  final alerts = FakeAlertScheduler();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
    outages: FakeOutageRepository(outages: history, clock: () => at),
    extra: [
      nowProvider.overrideWith((ref) => Stream.value(at.toUtc())),
      alertSchedulerProvider.overrideWithValue(alerts),
    ],
  );
  return alerts;
}

void main() {
  testWidgets('a learned 7 PM outage schedules a 6:30 PM heads-up', (
    tester,
  ) async {
    final alerts = await _pump(tester, history: _eveningCuts());
    final alert = alerts.pending!;
    expect(alert.atUtc, DateTime(2026, 10, 11, 18, 30).toUtc());
    expect(alert.title, 'Power may go at 7:00 PM');
    expect(alert.body, contains('Battery will be about 96%'));
    expect(alert.body, contains('6h 14m'));
  });

  testWidgets('no prediction, no alert', (tester) async {
    final alerts = await _pump(tester);
    expect(alerts.pending, isNull);
  });

  testWidgets('too close to the outage for a heads-up: no alert', (
    tester,
  ) async {
    final alerts = await _pump(
      tester,
      history: _eveningCuts(),
      now: DateTime(2026, 10, 11, 18, 45),
    );
    expect(alerts.pending, isNull);
  });

  testWidgets('the power going cancels the pending alert', (tester) async {
    final alerts = await _pump(tester, history: _eveningCuts());
    expect(alerts.pending, isNotNull);
    await tester.tap(find.text('Power gone?'));
    await tester.pumpAndSettle();
    expect(alerts.pending, isNull);
  });

  testWidgets('switching alerts off in Settings cancels, on reschedules', (
    tester,
  ) async {
    final alerts = await _pump(tester, history: _eveningCuts());
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    final toggle = find.text('Outage alerts');
    await tester.scrollUntilVisible(
      toggle,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final control = find.descendant(
      of: find.ancestor(of: toggle, matching: find.byType(MergeSemantics)),
      matching: find.byType(BbSwitch),
    );
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(alerts.pending, isNull);

    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(alerts.pending, isNotNull);
  });

  testWidgets('tapping an alert opens the Outages screen', (tester) async {
    final alerts = await _pump(tester, history: _eveningCuts());
    alerts.tapController.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Your area\'s schedule'), findsOneWidget);
  });
}
