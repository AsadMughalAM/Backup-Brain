import 'package:backup_brain/core/services/clock.dart';
import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

/// The morning after the fixture's first day, so "Yesterday" has a whole
/// day of recorded weather.
final _nextMorning = lahoreMorning.add(const Duration(days: 1));

Future<FakeSolarLogRepository> _openCheck(WidgetTester tester) async {
  final logs = FakeSolarLogRepository();
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
    solarLogs: logs,
    weather: FakeWeatherRepository(saved: lahoreForecast()),
    extra: [nowProvider.overrideWith((ref) => Stream.value(_nextMorning))],
  );
  await tester.tap(
    find.descendant(of: find.byType(BbNavBar), matching: find.text('Solar')),
  );
  await tester.pumpAndSettle();
  final open = find.text('Are my panels working well?');
  await tester.scrollUntilVisible(
    open,
    300,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.ensureVisible(open);
  await tester.pumpAndSettle();
  await tester.tap(open);
  await tester.pumpAndSettle();
  return logs;
}

void main() {
  testWidgets('yesterday\'s output against that day\'s weather', (
    tester,
  ) async {
    final logs = await _openCheck(tester);
    expect(find.text('No check yet'), findsOneWidget);
    expect(find.textContaining('should make about'), findsOneWidget);

    // Far below what a 2.16 kWp system makes on a sunny October day.
    await tester.enterText(find.byType(EditableText), '1.0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final log = logs.logs.single;
    expect(log.day, DateTime.utc(2026, 10, 11));
    expect(log.actualKWh, 1.0);
    expect(log.expectedKWh, greaterThan(1.0));
    expect(find.text('A little low'), findsOneWidget);
  });

  testWidgets('a nonsense entry asks for a number instead of saving', (
    tester,
  ) async {
    final logs = await _openCheck(tester);
    await tester.enterText(find.byType(EditableText), 'abc');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number, e.g. 8.5'), findsOneWidget);
    expect(logs.logs, isEmpty);
  });
}
