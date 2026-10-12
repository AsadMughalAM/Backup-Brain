import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// 3 PM local on Sunday 11 Oct 2026. Local, so the tests read the same in
/// any time zone.
final _now = DateTime(2026, 10, 11, 15);

/// Every evening at 7 PM for 1h 30m, on the five days before [_now].
List<OutageEvent> _eveningCuts() => [
  for (var d = 1; d <= 5; d++)
    OutageEvent(
      id: 'past$d',
      startedAt: DateTime(2026, 10, 11 - d, 19),
      endedAt: DateTime(2026, 10, 11 - d, 20, 30),
    ),
];

Future<({FakeOutageRepository outages, FakeSystemRepository system})> _pump(
  WidgetTester tester, {
  List<OutageEvent> history = const [],
  DateTime? now,
}) async {
  final at = now ?? _now;
  final outages = FakeOutageRepository(outages: history);
  final system = FakeSystemRepository(demoSystem());
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: system,
    appliances: FakeApplianceRepository(demoAppliances()),
    outages: outages,
    extra: [nowProvider.overrideWith((ref) => Stream.value(at.toUtc()))],
  );
  return (outages: outages, system: system);
}

/// The outage card sits below the fold on a phone-sized screen.
/// Scrolls [finder] fully on screen: built is not the same as visible, and
/// the floating nav bar covers the bottom of the list.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('learned evening pattern: next outage and the battery by then', (
    tester,
  ) async {
    await _pump(tester, history: _eveningCuts());
    await _reveal(tester, find.text('Next outage likely 7:00 PM'));
    // 4 h of grid at 360 W × 0.9 from 60%: 9%/h to 95% (3.9 h), then half
    // rate = 95.5%; (0.955 − 0.15) × 3600 Wh × 0.9 / 420 W = 6h 12m.
    expect(find.text('Battery 96% by then · lasts 6h 12m'), findsOneWidget);
  });

  testWidgets('no logs or schedule yet: says how to get a prediction', (
    tester,
  ) async {
    await _pump(tester);
    await _reveal(tester, find.text('No outage pattern yet'));
  });

  testWidgets('"Power gone?" then "Power back?" logs one outage and sets '
      'the battery to the engine estimate', (tester) async {
    final outageStart = _now;
    final logged = await _pump(tester, now: outageStart);

    await tester.tap(find.text('Power gone?'));
    await tester.pumpAndSettle();
    expect(find.text('Power back?'), findsOneWidget);
    await _reveal(tester, find.text('Power cut for 0m'));
    await tester.scrollUntilVisible(
      find.text('Power back?'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Power back?'));
    await tester.pumpAndSettle();
    final cut = logged.outages.outages.single;
    expect(cut.isOngoing, isTrue);
    expect(cut.startSoc, 0.6);
    expect(cut.avgLoadW, 420);

    await tester.tap(find.text('Power back?'));
    await tester.pumpAndSettle();
    expect(logged.outages.outages.single.isOngoing, isFalse);
    expect(find.text('Power on'), findsOneWidget);
    // No time passed in the test clock, so the battery is unchanged.
    expect(logged.system.current!.soc, closeTo(0.6, 1e-9));
  });

  testWidgets('an outage in progress shows the battery draining', (
    tester,
  ) async {
    await _pump(
      tester,
      history: [
        OutageEvent(
          id: 'now',
          startedAt: _now.subtract(const Duration(hours: 1)),
          startSoc: 0.6,
          avgLoadW: 420,
        ),
      ],
    );
    await _reveal(tester, find.text('Power cut for 1h 0m'));
    // 420 W for 1 h takes 12.96% of 3600 Wh: 60% → 47%.
    expect(find.textContaining('Battery about 47% now'), findsOneWidget);
  });

  testWidgets('schedule: two cuts a day, every day, saved together; an exact '
      'time can be typed', (tester) async {
    final logged = await _pump(tester);
    await _reveal(tester, find.byTooltip('Outages and schedule'));
    await tester.tap(find.byTooltip('Outages and schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add time'));
    await tester.pumpAndSettle();

    // Time 1: 7–9 PM. Time 2 starts 4 h after it ends: 1–3 AM.
    await tester.tap(find.text('Add another time'));
    await tester.pumpAndSettle();
    expect(find.text('Time 2'), findsOneWidget);
    expect(find.text('1:00 AM'), findsOneWidget);

    // Type 7:15 PM for time 1's start instead of stepping half hours.
    await tester.tap(find.text('7:00 PM'));
    await tester.pumpAndSettle();
    final hour = find.byType(TextField).at(0);
    final minute = find.byType(TextField).at(1);
    await tester.enterText(hour, '7');
    await tester.enterText(minute, '15');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('7:15 PM'), findsOneWidget);
    expect(find.text('1h 45m without power'), findsOneWidget);

    await tester.tap(find.text('Save 2 times'));
    await tester.pumpAndSettle();
    final slots = logged.outages.schedule;
    expect(slots, hasLength(14)); // 2 times × 7 days
    expect(slots.map((e) => (e.slot.startMinute, e.slot.endMinute)).toSet(), {
      (19 * 60 + 15, 21 * 60),
      (60, 3 * 60),
    });
  });

  testWidgets('schedule: add a Sunday evening slot, then remove it', (
    tester,
  ) async {
    final logged = await _pump(tester);
    await _reveal(tester, find.byTooltip('Outages and schedule'));
    await tester.tap(find.byTooltip('Outages and schedule'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add time'));
    await tester.pumpAndSettle();

    // Every day starts picked; clearing them and saving explains why
    // nothing was saved instead of failing silently.
    await tester.tap(find.text('Clear days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Pick at least one day.'), findsOneWidget);

    await tester.tap(find.text('Sun'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Sun 7:00 PM–9:00 PM'), findsOneWidget);
    expect(find.text('Scheduled outage 7:00 PM'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove Sun 7:00 PM–9:00 PM'));
    await tester.pumpAndSettle();
    expect(logged.outages.schedule, isEmpty);
    expect(find.text('No outage pattern yet'), findsOneWidget);
  });
}
