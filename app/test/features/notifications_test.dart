import 'dart:convert';

import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
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

Future<void> _pump(
  WidgetTester tester, {
  List<OutageEvent> history = const [],
  Map<String, Object> saved = const {},
}) => pumpApp(
  tester,
  auth: FakeAuthRepository(account: signedInAsAsad),
  system: FakeSystemRepository(demoSystem()),
  appliances: FakeApplianceRepository(demoAppliances()),
  outages: FakeOutageRepository(outages: history),
  saved: saved,
  extra: [nowProvider.overrideWith((ref) => Stream.value(_now.toUtc()))],
);

/// A heads-up the phone showed at 2 PM today, an hour ago.
Map<String, Object> _shownAt2pm() => {
  'notificationInbox': json.encode([
    {
      'kind': 'outageAlert',
      'at': DateTime(2026, 10, 11, 14).toUtc().toIso8601String(),
      'title': 'Load-shedding at 2:30 PM',
      'body': 'Battery will be about 90%.',
    },
  ]),
};

void main() {
  testWidgets('the bell lists the heads-up the phone will show next', (
    tester,
  ) async {
    await _pump(tester, history: _eveningCuts());
    // Nothing shown yet: no count on the bell.
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Coming up'), findsOneWidget);
    expect(find.text('Power may go at 7:00 PM'), findsOneWidget);
    expect(find.text('At 6:30 PM'), findsOneWidget);
    expect(find.text('Nothing has been shown yet.'), findsOneWidget);
  });

  testWidgets('a shown notification counts on the bell until the list is '
      'opened', (tester) async {
    await _pump(tester, saved: _shownAt2pm());
    expect(find.byTooltip('Notifications, 1 new'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // the badge

    await tester.tap(find.byTooltip('Notifications, 1 new'));
    await tester.pumpAndSettle();
    expect(find.text('Load-shedding at 2:30 PM'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('1 h ago'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Notifications'), findsOneWidget);
  });

  testWidgets('nothing set yet: says how to get notifications', (tester) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
    await tester.tap(find.text('Add load-shedding times'));
    await tester.pumpAndSettle();
    expect(find.text('Add time'), findsOneWidget); // the Outages screen
  });
}
