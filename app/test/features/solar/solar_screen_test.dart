import 'package:backup_brain/app/app.dart';
import 'package:bb_ui/bb_ui.dart';
import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:backup_brain/features/outages/domain/outage_notifier.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:backup_brain/features/solar/domain/weather_repository.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';

/// Opens the app on the demo household at [now] and goes to the Solar tab.
Future<void> _openSolar(
  WidgetTester tester, {
  required FakeWeatherRepository weather,
  DateTime? now,
  FakeOutageRepository? outages,
  FakeSystemRepository? system,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        systemRepositoryProvider.overrideWithValue(
          system ?? FakeSystemRepository(demoSystem()),
        ),
        applianceRepositoryProvider.overrideWithValue(
          FakeApplianceRepository(demoAppliances()),
        ),
        weatherRepositoryProvider.overrideWithValue(weather),
        outageRepositoryProvider.overrideWithValue(
          outages ?? FakeOutageRepository(),
        ),
        outageNotifierProvider.overrideWithValue(FakeOutageNotifier()),
        nowProvider.overrideWith((ref) => Stream.value(now ?? lahoreMorning)),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Solar'));
  await tester.pumpAndSettle();
}

/// The Solar list builds lazily; scroll until [text] is on screen.
Future<Finder> _see(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  return finder;
}

void main() {
  testWidgets('8 AM on a cloudy day: the verdict, the why and what to do', (
    tester,
  ) async {
    final weather = FakeWeatherRepository(saved: lahoreForecast());
    await _openSolar(tester, weather: weather);

    expect(find.text('Battery reaches 79% by sunset'), findsOneWidget);
    expect(find.text('Starting from 60% now'), findsOneWidget);
    expect(find.text('at sunset, 5:30 PM'), findsOneWidget);
    expect(find.text('Lasts until about 10:25 PM at 420 W'), findsOneWidget);
    expect(
      find.text(
        'Weak sun. Your battery may reach only 79%, so avoid heavy loads '
        'after 5:30 PM.',
      ),
      findsOneWidget,
    );
    expect(await _see(tester, '49% less sun than a clear day'), findsOneWidget);
    expect(await _see(tester, 'Lahore · updated 20 min ago'), findsOneWidget);
    // A 20-minute-old forecast is fresh: no fetch.
    expect(weather.refreshCalls, 0);
  });

  testWidgets('hero text is readable on the midnight hero card', (
    tester,
  ) async {
    await _openSolar(
      tester,
      weather: FakeWeatherRepository(saved: lahoreForecast()),
    );
    final hero = AppTheme.light().extension<AppColors>()!.hero;
    for (final text in [
      'Battery reaches 79% by sunset',
      'Starting from 60% now',
    ]) {
      final color = tester.widget<Text>(find.text(text)).style!.color!;
      expect(contrastRatio(color, hero), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('one tap for tomorrow (demo step 4)', (tester) async {
    await _openSolar(
      tester,
      weather: FakeWeatherRepository(saved: lahoreForecast()),
    );
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();

    expect(find.text('Battery reaches 73% by sunset'), findsOneWidget);
    expect(find.text('If it starts the day at 15%'), findsOneWidget);
    expect(await _see(tester, '19% less sun than a clear day'), findsOneWidget);
    expect(
      find.text(
        'Most sun from 10:00 AM to 1:00 PM. Run heavy loads like the iron '
        'or water motor then.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('after sunset, tomorrow is picked for you', (tester) async {
    await _openSolar(
      tester,
      weather: FakeWeatherRepository(saved: lahoreForecast()),
      now: DateTime.utc(2026, 10, 11, 15), // 8 PM PKT
    );
    expect(find.text('If it starts the day at 15%'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('No more sun today'), findsOneWidget);
  });

  testWidgets('stale forecast: shown at once, refreshed in the background', (
    tester,
  ) async {
    final weather = FakeWeatherRepository(
      saved: lahoreForecast(
        fetchedAt: lahoreMorning.subtract(const Duration(hours: 3)),
      ),
      onRefresh: lahoreForecast,
    );
    await _openSolar(tester, weather: weather);
    expect(weather.refreshCalls, 1);
    expect(await _see(tester, 'Lahore · updated 20 min ago'), findsOneWidget);
  });

  testWidgets('update fails: keep the saved forecast and offer a retry', (
    tester,
  ) async {
    final weather = FakeWeatherRepository(
      saved: lahoreForecast(
        fetchedAt: lahoreMorning.subtract(const Duration(hours: 3)),
      ),
    );
    await _openSolar(tester, weather: weather);
    expect(find.text('Battery reaches 79% by sunset'), findsOneWidget);
    expect(await _see(tester, 'Lahore · updated 3 h ago'), findsOneWidget);
    expect(
      await _see(tester, "Couldn't update. Showing the saved forecast."),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('never fetched and offline: needs internet once', (tester) async {
    final weather = FakeWeatherRepository();
    await _openSolar(tester, weather: weather);
    expect(find.text('Needs internet once'), findsOneWidget);
    expect(weather.refreshCalls, 1);
  });

  testWidgets('a scheduled cut in a weak-sun hour: the battery covers it, '
      'and the hero says so', (tester) async {
    // 7–10 AM in Lahore, written in this machine's local time.
    final start = DateTime.utc(2026, 10, 11, 2).toLocal();
    final slot = ScheduleSlot(
      weekday: start.weekday,
      startMinute: start.hour * 60 + start.minute,
      endMinute: (start.hour + 3) * 60 + start.minute,
    );
    await _openSolar(
      tester,
      weather: FakeWeatherRepository(saved: lahoreForecast()),
      outages: FakeOutageRepository(schedule: [ScheduleEntry('s1', slot)]),
    );
    expect(find.textContaining('Counts the power cut from'), findsOneWidget);
    // Without the cut the battery reaches 79%; the morning cut costs some.
    expect(find.text('Battery reaches 79% by sunset'), findsNothing);
    expect(find.textContaining('Battery reaches'), findsOneWidget);
  });

  testWidgets('"Cleaned today" tells the forecast the panels are clean', (
    tester,
  ) async {
    final system = FakeSystemRepository(demoSystem());
    await _openSolar(
      tester,
      weather: FakeWeatherRepository(saved: lahoreForecast()),
      system: system,
    );
    expect(await _see(tester, 'Panels: last cleaning unknown'), findsOneWidget);
    await tester.ensureVisible(find.text('Cleaned today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cleaned today'));
    await tester.pumpAndSettle();
    expect(system.current!.solar!.lastCleanedAt, lahoreMorning);
    expect(await _see(tester, 'Panels cleaned just now'), findsOneWidget);
    expect(find.text('Cleaned today'), findsNothing);
  });

  testWidgets('coming back to the app refreshes a stale forecast', (
    tester,
  ) async {
    final weather = FakeWeatherRepository(
      saved: lahoreForecast(
        fetchedAt: lahoreMorning.subtract(const Duration(hours: 3)),
      ),
    );
    await _openSolar(tester, weather: weather);
    expect(weather.refreshCalls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(weather.refreshCalls, 2);
  });
}
