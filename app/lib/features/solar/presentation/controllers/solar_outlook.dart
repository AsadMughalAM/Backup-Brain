import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock.dart';
import '../../../backup/domain/system_repository.dart';
import '../../../loads/domain/appliance_repository.dart';
import '../../domain/weather_repository.dart';

/// F3 for both days, ready to show. Every number on the Solar screen comes
/// from here.
class SolarOutlook {
  const SolarOutlook({
    required this.today,
    required this.tomorrow,
    required this.city,
    required this.fetchedAt,
    required this.utcOffset,
    required this.loadW,
  });

  /// Charging from the current SoC, from now on.
  final SolarDayForecast? today;

  /// Charging from the battery's cutoff SoC — the honest worst case after a
  /// night on backup.
  final SolarDayForecast? tomorrow;

  final String city;
  final DateTime fetchedAt;

  /// Clock times are shown in the panels' local time.
  final Duration utcOffset;

  /// The house load the forecast assumes (the planner's current load).
  final double loadW;
}

/// Null until the system, appliances and a saved forecast are all there,
/// or when the household has no panels or location.
final solarOutlookProvider = Provider<SolarOutlook?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final plan = ref.watch(loadPlanProvider);
  final forecast = ref.watch(latestForecastProvider).value;
  final now = ref.watch(nowProvider).value;
  final solar = system?.solar;
  final location = system?.location;
  if (system == null ||
      plan == null ||
      forecast == null ||
      now == null ||
      solar == null ||
      location == null) {
    return null;
  }

  const model = SolarModel();
  final loadW = plan.current.loadW;
  SolarDayForecast? day(int offset, BackupInput battery, DateTime? from) {
    final hours = forecast.hoursOn(now, dayOffset: offset);
    if (hours.isEmpty) return null;
    return model.forecastDay(
      solar: solar,
      site: location.site,
      hours: hours,
      battery: battery,
      loadW: loadW,
      from: from,
    );
  }

  return SolarOutlook(
    today: day(0, system.backupInput, now),
    tomorrow: day(
      1,
      system.copyWith(soc: system.battery.cutoffSoc).backupInput,
      null,
    ),
    city: location.city,
    fetchedAt: forecast.fetchedAt,
    utcOffset: forecast.utcOffset,
    loadW: loadW,
  );
});
