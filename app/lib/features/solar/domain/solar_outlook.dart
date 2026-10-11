import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../backup/domain/battery_estimate.dart';
import '../../backup/domain/system_repository.dart';
import '../../loads/domain/load_plan.dart';
import '../../outages/domain/outage_repository.dart';
import 'weather_repository.dart';

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
    this.offGrid = const [],
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

  /// Expected power cuts in the next two days (F8). During them the battery
  /// covers what the panels can't.
  final List<OutageWindow> offGrid;

  /// The first expected cut overlapping [day]'s remaining daylight, to
  /// say what the forecast assumes.
  OutageWindow? cutDuring(SolarDayForecast day, DateTime now) {
    final from = day.sunIsOver ? day.sunset : _later(day.sunrise, now);
    for (final w in offGrid) {
      if (w.hoursWithin(from, day.sunset) > 0) return w;
    }
    return null;
  }

  static DateTime _later(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
}

/// Two days: today and tomorrow's forecast.
const _windowHours = 48.0;

/// Null until the system, appliances and a saved forecast are all there,
/// or when the household has no panels or location.
final solarOutlookProvider = Provider<SolarOutlook?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final plan = ref.watch(loadPlanProvider);
  final forecast = ref.watch(latestForecastProvider).value;
  final charge = ref.watch(batteryEstimateProvider);
  final outages = ref.watch(recentOutagesProvider).value ?? const [];
  final schedule = ref.watch(scheduleProvider).value ?? const [];
  final now = ref.watch(nowProvider).value;
  final solar = system?.solar;
  final location = system?.location;
  if (system == null ||
      plan == null ||
      charge == null ||
      forecast == null ||
      now == null ||
      solar == null ||
      location == null) {
    return null;
  }

  const model = SolarModel();
  final loadW = plan.current.loadW;
  final offGrid = const OutagePattern().expectedWindows(
    now: now.toLocal(),
    hours: _windowHours,
    history: [for (final o in outages) o.record],
    schedule: [for (final e in schedule) e.slot],
  );
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
      offGrid: offGrid,
    );
  }

  return SolarOutlook(
    today: day(0, system.copyWith(soc: charge.soc).backupInput, now),
    tomorrow: day(
      1,
      system.copyWith(soc: system.battery.cutoffSoc).backupInput,
      null,
    ),
    city: location.city,
    fetchedAt: forecast.fetchedAt,
    utcOffset: forecast.utcOffset,
    loadW: loadW,
    offGrid: offGrid,
  );
});
