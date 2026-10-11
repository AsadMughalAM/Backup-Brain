import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../backup/domain/system_repository.dart';
import 'weather_repository.dart';

/// One day's output the user read off the inverter, with what the model
/// expected for that day's weather (ARCHITECTURE.md §8 SolarDailyLog).
/// Expected is stored because the weather for old days leaves the cache.
class SolarLog {
  const SolarLog({
    required this.day,
    required this.actualKWh,
    required this.expectedKWh,
    required this.clearShare,
  });

  /// Local calendar day, as a UTC midnight.
  final DateTime day;
  final double actualKWh;
  final double expectedKWh;
  final double clearShare;

  DayPerformance get performance => DayPerformance(
    day: day,
    actualKWh: actualKWh,
    expectedKWh: expectedKWh,
    clearShare: clearShare,
  );
}

abstract interface class SolarLogRepository {
  /// Newest first, the last month.
  Stream<List<SolarLog>> watchRecent();

  /// One log per day: saving the same day again replaces it.
  Future<void> save(SolarLog log);
}

/// Bound in `app/app_providers.dart`.
final solarLogRepositoryProvider = Provider<SolarLogRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final solarLogsProvider = StreamProvider<List<SolarLog>>(
  (ref) => ref.watch(solarLogRepositoryProvider).watchRecent(),
);

/// F4 verdict over the logs; null until a day with enough sun is logged.
final solarPerformanceProvider = Provider<PerformanceStatus?>((ref) {
  final logs = ref.watch(solarLogsProvider).value ?? const [];
  return const SolarPerformance().status([for (final l in logs) l.performance]);
});

/// What the model expected on the local day [dayOffset] days from today
/// (0 = today, -1 = yesterday), from the saved weather. Null when the
/// household has no panels or the weather doesn't cover that day.
final dayExpectationProvider = Provider.family<DayExpectation?, int>((
  ref,
  dayOffset,
) {
  final system = ref.watch(householdSystemProvider).value;
  final forecast = ref.watch(latestForecastProvider).value;
  final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
  final solar = system?.solar;
  final location = system?.location;
  if (system == null || forecast == null || solar == null || location == null) {
    return null;
  }
  final hours = forecast.hoursOn(now, dayOffset: dayOffset);
  // A partial day would under-count; Open-Meteo gives whole local days.
  if (hours.length < Duration.hoursPerDay) return null;
  final day = const SolarModel().forecastDay(
    solar: solar,
    site: location.site,
    hours: hours,
    battery: system.backupInput,
    loadW: 0,
  );
  final local = now.add(forecast.utcOffset);
  return DayExpectation(
    day: DateTime.utc(local.year, local.month, local.day + dayOffset),
    expectedKWh: day.expectedKWh,
    clearShare: day.clearSkyKWh <= 0 ? 0 : day.expectedKWh / day.clearSkyKWh,
  );
});

class DayExpectation {
  const DayExpectation({
    required this.day,
    required this.expectedKWh,
    required this.clearShare,
  });

  final DateTime day;
  final double expectedKWh;
  final double clearShare;
}
