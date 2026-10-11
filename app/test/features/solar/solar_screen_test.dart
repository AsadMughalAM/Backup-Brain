import 'package:backup_brain/app/app.dart';
import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:backup_brain/features/solar/domain/weather_repository.dart';
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
          FakeSystemRepository(demoSystem()),
        ),
        applianceRepositoryProvider.overrideWithValue(
          FakeApplianceRepository(demoAppliances()),
        ),
        weatherRepositoryProvider.overrideWithValue(weather),
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
}
