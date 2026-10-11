import 'package:backup_brain/app/app.dart';
import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/features/battery/presentation/controllers/reading_controller.dart';
import 'package:bb_ui/bb_ui.dart';
import 'package:backup_brain/features/backup/domain/entities/household_system.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// 7 PM local on Sunday 11 Oct 2026. Local, so the tests read the same in
/// any time zone.
final _sevenPm = DateTime(2026, 10, 11, 19);

/// The demo household (24 V 150 Ah LiFePO4 = 3600 Wh, cutoff 15%, 90%
/// inverter, 420 W on), with its charge read by the user at [checkedAt].
HouseholdSystem _checked(double soc, DateTime checkedAt) =>
    demoSystem().copyWith(
      soc: soc,
      socAt: checkedAt.toUtc(),
      socCheckedAt: checkedAt.toUtc(),
    );

typedef _Home = ({
  FakeSystemRepository system,
  FakeOutageRepository outages,
  FakeApplianceRepository appliances,
  FakeOutageNotifier notifier,
  TestClock clock,
});

Future<_Home> _pump(
  WidgetTester tester, {
  HouseholdSystem? system,
  List<OutageEvent> history = const [],
  DateTime? now,
}) async {
  final clock = TestClock(now ?? _sevenPm);
  final home = (
    system: FakeSystemRepository(system ?? demoSystem()),
    outages: FakeOutageRepository(outages: history),
    appliances: FakeApplianceRepository(demoAppliances()),
    notifier: FakeOutageNotifier(),
    clock: clock,
  );
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: home.system,
    appliances: home.appliances,
    outages: home.outages,
    notifier: home.notifier,
    extra: [nowProvider.overrideWith((ref) => clock.stream())],
  );
  return home;
}

Future<void> _advance(WidgetTester tester, _Home home, Duration by) async {
  home.clock.advance(by);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

final _tile = find.widgetWithText(BbStatTile, 'Battery');

/// Scrolls Home back to the top, then down until [finder] is built.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final list = find.byType(Scrollable).first;
  await tester.drag(list, const Offset(0, 2000));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(finder, 150, scrollable: list);
}

/// Taps something on Home, scrolling to it first.
Future<void> _tapHome(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await _tap(tester, finder);
}

/// The Battery tile's value: the number above "%".
Future<String> _batteryTile(WidgetTester tester) async {
  await _reveal(tester, _tile);
  return tester.widget<BbStatTile>(_tile).value;
}

void main() {
  testWidgets('a power cut, start to finish: the countdown drains, a load '
      'change counts from then, and the battery charges back', (tester) async {
    // Read at 80% an hour ago; the grid charged it since: +9%/h (C/10 =
    // 360 W × 0.90 into 3600 Wh) = 89% at 7 PM.
    final home = await _pump(
      tester,
      system: _checked(0.8, _sevenPm.subtract(const Duration(hours: 1))),
    );
    expect(await _batteryTile(tester), '85');

    await _tapHome(tester, find.text('Power gone?'));
    final cut = home.outages.outages.single;
    expect(cut.startedAt, _sevenPm.toUtc());
    expect(home.system.current!.soc, closeTo(0.89, 1e-9));
    expect(home.system.current!.socAt, _sevenPm.toUtc());
    // (0.89 − 0.15) × 3600 × 0.9 / 420 W = 5.71 h, shown to 10 minutes.
    await _reveal(tester, find.text('5h 40m'));
    await _reveal(tester, find.text('Since 7:00 PM'));
    // Read 1 h ago: no need to ask again.
    expect(find.text('What does your UPS screen show?'), findsNothing);

    // An hour on battery: 420 W / 0.9 = 467 Wh = 13% → 76%.
    await _advance(tester, home, const Duration(hours: 1));
    expect(await _batteryTile(tester), '75');
    await _reveal(tester, find.text('4h 40m'));
    expect(find.text('Estimate · you checked 2 h ago'), findsOneWidget);

    // Switching the TV off during the cut saves the drain so far first.
    await tester.tap(find.text('Loads'));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('LED TV').last);
    expect(home.system.current!.soc, closeTo(0.89 - 420 / 0.9 / 3600, 1e-9));
    expect(
      home.system.current!.socAt,
      _sevenPm.add(const Duration(hours: 1)).toUtc(),
    );
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    // (0.7604 − 0.15) × 3240 / 330 W = 5.99 h.
    await _reveal(tester, find.text('5h 50m'));

    // Another hour at 330 W, then the power comes back.
    await _advance(tester, home, const Duration(hours: 1));
    final atReturn = 0.89 - 420 / 0.9 / 3600 - 330 / 0.9 / 3600;
    await _tapHome(tester, find.text('Power back?'));
    expect(home.outages.outages.single.isOngoing, isFalse);
    expect(home.system.current!.soc, closeTo(atReturn, 1e-9));
    // F6 gets the cut's real average load: 1 h at 420 W, 1 h at 330 W.
    expect(home.outages.outages.single.avgLoadW, closeTo(375, 1e-6));
    await _reveal(tester, find.text('Power on'));
    expect(find.text('Since 7:00 PM'), findsNothing);

    // Two hours of grid: 65.9% + 18% = 83.9%, shown rounded down.
    await _advance(tester, home, const Duration(hours: 2));
    expect(await _batteryTile(tester), '80');
  });

  testWidgets('never read: one question when the power goes, one tap '
      'answers it', (tester) async {
    final home = await _pump(tester);
    expect(find.text('What does your UPS screen show?'), findsNothing);

    await _tapHome(tester, find.text('Power gone?'));
    expect(find.text('What does your UPS screen show?'), findsOneWidget);
    await _tap(tester, find.text('75%'));

    expect(home.system.current!.soc, 0.75);
    expect(home.system.current!.socCheckedAt, _sevenPm.toUtc());
    expect(find.text('What does your UPS screen show?'), findsNothing);
    expect(await _batteryTile(tester), '75');
    expect(find.text('Checked by you just now'), findsOneWidget);
  });

  testWidgets('"Not now" puts the question off for this cut, even after a '
      'restart', (tester) async {
    final cut = OutageEvent(id: 'cut1', startedAt: _sevenPm, startSoc: 0.6);
    await _pump(tester, history: [cut]);
    await _tapHome(tester, find.text('Not now'));
    expect(find.text('What does your UPS screen show?'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('batteryCheck.dismissedOutage'), 'cut1');
  });

  testWidgets('the Battery tile opens the same question as a sheet that '
      'closes on Escape, a scrim tap or an answer', (tester) async {
    final home = await _pump(tester);

    await _tapHome(tester, _tile);
    expect(find.text('What does your UPS screen show?'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('What does your UPS screen show?'), findsNothing);

    await _tapHome(tester, _tile);
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();
    expect(find.text('What does your UPS screen show?'), findsNothing);

    await _tapHome(tester, _tile);
    await _tap(tester, find.text('25%'));
    expect(find.text('What does your UPS screen show?'), findsNothing);
    expect(home.system.current!.soc, 0.25);
  });

  testWidgets('logged late: "30 min ago" moves the start and the drain '
      'with it; "didn\'t go" removes the cut', (tester) async {
    final home = await _pump(
      tester,
      system: _checked(0.8, _sevenPm.subtract(const Duration(hours: 3))),
    );
    await _tapHome(tester, find.text('Power gone?'));
    await _tapHome(tester, find.text('Change'));
    expect(find.text('When did the power go?'), findsOneWidget);
    await _tap(tester, find.text('30 min ago'));

    final halfPastSix = _sevenPm.subtract(const Duration(minutes: 30));
    expect(home.outages.outages.single.startedAt, halfPastSix.toUtc());
    expect(home.system.current!.socAt, halfPastSix.toUtc());
    await _reveal(tester, find.text('Since 6:30 PM'));

    await _tapHome(tester, find.text('Change'));
    await _tap(tester, find.text("The power didn't go"));
    expect(home.outages.outages, isEmpty);
    await _reveal(tester, find.text('Power on'));
  });

  testWidgets('a cut logged by an older version still drains from its own '
      'start', (tester) async {
    await _pump(
      tester,
      history: [
        OutageEvent(
          id: 'old',
          startedAt: _sevenPm.subtract(const Duration(hours: 1)),
          startSoc: 0.6,
          avgLoadW: 420,
        ),
      ],
    );
    // 60% − 13% = 47% → shown rounded down to 45.
    expect(await _batteryTile(tester), '45');
  });

  testWidgets('a battery reading after the power came back (F6) becomes '
      'the known charge from that moment', (tester) async {
    final back = _sevenPm.subtract(const Duration(hours: 2));
    final home = await _pump(
      tester,
      history: [
        OutageEvent(
          id: 'cut',
          startedAt: back.subtract(const Duration(hours: 1)),
          endedAt: back,
          startSoc: 0.8,
          endSoc: 0.67,
          avgLoadW: 420,
        ),
      ],
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    container.read(readingControllerProvider).save('cut', 0.5);
    await tester.pumpAndSettle();

    expect(home.outages.outages.single.endSocMeasured, isTrue);
    expect(home.system.current!.soc, 0.5);
    expect(home.system.current!.socAt, back.toUtc());
    expect(home.system.current!.socCheckedAt, back.toUtc());
    // Two hours of grid since: 50% + 18% = 68%, shown rounded down.
    expect(await _batteryTile(tester), '65');
  });
}
