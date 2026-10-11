import 'dart:math' as math;

import 'backup_calculator.dart';
import 'defaults.dart';
import 'models/hourly_weather.dart';
import 'models/solar_spec.dart';
import 'outage_pattern.dart';
import 'solar_geometry.dart';

/// One daylight hour of expected generation.
final class SolarHour {
  const SolarHour({
    required this.endsAt,
    required this.expectedWh,
    required this.clearSkyWh,
  });

  final DateTime endsAt;
  final double expectedWh;

  /// What the same panels would make under a cloudless sky.
  final double clearSkyWh;
}

final class SolarDayForecast {
  const SolarDayForecast({
    required this.hours,
    required this.expectedKWh,
    required this.lowKWh,
    required this.highKWh,
    required this.clearSkyKWh,
    required this.sunrise,
    required this.sunset,
    required this.startSoc,
    required this.socAtSunset,
    required this.fullAt,
    required this.sunIsOver,
    required this.night,
    required this.nightEndsAt,
    required this.lastsUntilSunrise,
    required this.peakWindow,
  });

  /// Daylight hours only, in order.
  final List<SolarHour> hours;

  /// Whole-day generation, with the honest range around it.
  final double expectedKWh;
  final double lowKWh;
  final double highKWh;
  final double clearSkyKWh;

  final DateTime sunrise;
  final DateTime sunset;

  /// SoC the simulation started from (now, or the cutoff for a later day).
  final double startSoc;
  final double socAtSunset;

  /// When the battery reaches 100%; null if it doesn't today or was
  /// already full at the start.
  final DateTime? fullAt;

  /// The simulation started at or after sunset: no more charging today.
  final bool sunIsOver;

  /// Backup after sunset (or from now, once the sun is over) at the load.
  final BackupEstimate night;

  /// When that backup runs out; null when nothing is drawing power.
  final DateTime? nightEndsAt;
  final bool lastsUntilSunrise;

  /// The sunniest [EngineDefaults.peakWindowHours] still ahead: the best
  /// time for heavy loads. Null when no sun is left.
  final ({DateTime start, DateTime end})? peakWindow;

  /// How much less sun than a clear day, 0–1 (0.35 = "35% less").
  double get belowClearSky =>
      clearSkyKWh <= 0 ? 0 : (1 - expectedKWh / clearSkyKWh).clamp(0.0, 1.0);
}

/// F3 — "Will solar charge my battery today/tomorrow?" (ARCHITECTURE.md §5
/// F3). Hourly generation from the weather forecast, then an hour-by-hour
/// battery simulation: solar covers the house load first and only the
/// surplus charges the battery. Where the load exceeds solar, the grid
/// covers the rest, except during an expected power cut, when the battery
/// does.
final class SolarModel {
  const SolarModel({this.calculator = const BackupCalculator()});

  final BackupCalculator calculator;

  /// [hours] are one local day's forecast. [battery].socNow is the starting
  /// SoC at [from] (or at the first hour when [from] is null). [loadW] is
  /// the house load, used for daytime consumption and the night backup.
  /// [offGrid] are the expected power cuts (F8): in them the battery covers
  /// what the panels can't.
  SolarDayForecast forecastDay({
    required SolarSpec solar,
    required SiteLocation site,
    required List<HourlyWeather> hours,
    required BackupInput battery,
    required double loadW,
    DateTime? from,
    List<OutageWindow> offGrid = const [],
  }) {
    _validate(solar, site, hours, loadW);
    final midday = hours[hours.length ~/ 2].endsAt;
    final daylight = SolarGeometry.daylight(site, midday);
    final day = [
      for (final h in hours) _hour(solar, site, h, midday),
    ].where((h) => h.expectedWh > 0 || h.clearSkyWh > 0).toList();

    final expectedKWh = _sumWh(day, (h) => h.expectedWh) / 1000;
    final clearSkyKWh = _sumWh(day, (h) => h.clearSkyWh) / 1000;
    const spread = EngineDefaults.solarForecastUncertainty;

    final ahead = [
      for (final h in day)
        if (from == null || h.endsAt.isAfter(from))
          (hour: h, start: _later(h.endsAt.subtract(_hour1), from)),
    ];
    final charge = _simulate(ahead, battery, loadW, offGrid);
    final sunIsOver = from != null && !from.isBefore(daylight.sunset);

    final night = calculator.estimate(
      BackupInput(
        battery: battery.battery,
        inverter: battery.inverter,
        socNow: charge.soc,
        healthFactor: battery.healthFactor,
      ),
      loadW: loadW,
    );
    final nightStart = from != null && sunIsOver ? from : daylight.sunset;
    final nightEndsAt = night.isUnlimited
        ? null
        : nightStart.add(_duration(night.hours));
    final nextSunrise = daylight.sunrise.add(const Duration(days: 1));

    return SolarDayForecast(
      hours: day,
      expectedKWh: expectedKWh,
      lowKWh: expectedKWh * (1 - spread),
      highKWh: math.max(expectedKWh * (1 + spread), clearSkyKWh),
      clearSkyKWh: clearSkyKWh,
      sunrise: daylight.sunrise,
      sunset: daylight.sunset,
      startSoc: battery.socNow,
      socAtSunset: charge.soc,
      fullAt: charge.fullAt,
      sunIsOver: sunIsOver,
      night: night,
      nightEndsAt: nightEndsAt,
      lastsUntilSunrise:
          nightEndsAt == null || !nightEndsAt.isBefore(nextSunrise),
      peakWindow: _peakWindow(ahead),
    );
  }

  static const _hour1 = Duration(hours: 1);

  SolarHour _hour(
    SolarSpec solar,
    SiteLocation site,
    HourlyWeather w,
    DateTime day,
  ) {
    final cleanedAt = solar.lastCleanedAt;
    final daysSinceCleaned = cleanedAt == null
        ? null
        : math.max(0, day.difference(cleanedAt).inDays);
    // kWp × 1000 × (G / 1000) cancels to kWp × G: Wh over one hour.
    final systemFactor =
        solar.kWp *
        (solar.performanceRatio ?? EngineDefaults.performanceRatio) *
        EngineDefaults.soilingFactor(daysSinceCleaned) *
        EngineDefaults.shadingFactor(solar.shading);
    final cellTemp = w.airTempC + EngineDefaults.panelTempRiseC;
    final tempDerate =
        1 -
        EngineDefaults.panelTempCoefficient *
            math.max(0, cellTemp - EngineDefaults.panelRatedTempC);
    final clearSky = SolarGeometry.clearSkyIrradiance(
      site,
      w.endsAt.subtract(_hour1 ~/ 2),
    );
    return SolarHour(
      endsAt: w.endsAt,
      expectedWh: systemFactor * w.irradianceWm2 * tempDerate,
      clearSkyWh: systemFactor * clearSky * tempDerate,
    );
  }

  static ({double soc, DateTime? fullAt}) _simulate(
    List<({SolarHour hour, DateTime start})> ahead,
    BackupInput battery,
    double loadW,
    List<OutageWindow> offGrid,
  ) {
    final capacityWh = battery.battery.nominalWh * battery.healthFactor;
    final efficiency = EngineDefaults.chargeEfficiency(
      battery.battery.chemistry,
    );
    final inverterEfficiency =
        battery.inverter.efficiency ??
        EngineDefaults.inverterEfficiency(battery.inverter.type);
    final cutoff = battery.battery.cutoffSoc;
    var soc = battery.socNow;
    DateTime? fullAt;
    for (final (:hour, :start) in ahead) {
      final span = hour.endsAt.difference(start);
      final share = span.inMicroseconds / _hour1.inMicroseconds;
      final surplusWh = (hour.expectedWh - loadW) * share;
      if (surplusWh < 0) {
        // Short of sun during a cut: the battery makes up the difference,
        // down to the cutoff where the inverter stops.
        final offHours = offGrid.fold(
          0.0,
          (sum, w) => sum + w.hoursWithin(start, hour.endsAt),
        );
        if (offHours == 0) continue;
        final drawnWh =
            (loadW - hour.expectedWh) * offHours / inverterEfficiency;
        soc = math.max(math.min(soc, cutoff), soc - drawnWh / capacityWh);
        continue;
      }
      if (soc >= 1 || surplusWh == 0) continue;
      final gain = surplusWh * efficiency / capacityWh;
      if (soc + gain < 1) {
        soc += gain;
        continue;
      }
      fullAt ??= start.add(span * ((1 - soc) / gain));
      soc = 1;
    }
    return (soc: soc, fullAt: fullAt);
  }

  static ({DateTime start, DateTime end})? _peakWindow(
    List<({SolarHour hour, DateTime start})> ahead,
  ) {
    final size = math.min(EngineDefaults.peakWindowHours, ahead.length);
    var bestWh = 0.0;
    int? best;
    for (var i = 0; i + size <= ahead.length; i++) {
      final wh = _sumWh(ahead.sublist(i, i + size), (a) => a.hour.expectedWh);
      if (wh > bestWh) (bestWh, best) = (wh, i);
    }
    if (best == null) return null;
    return (start: ahead[best].start, end: ahead[best + size - 1].hour.endsAt);
  }

  static double _sumWh<T>(Iterable<T> items, double Function(T) wh) =>
      items.fold(0.0, (sum, i) => sum + wh(i));

  static DateTime _later(DateTime a, DateTime? b) =>
      b != null && b.isAfter(a) ? b : a;

  static Duration _duration(double hours) =>
      Duration(microseconds: (hours * Duration.microsecondsPerHour).round());

  static void _validate(
    SolarSpec solar,
    SiteLocation site,
    List<HourlyWeather> hours,
    double loadW,
  ) {
    _check(solar.kWp > 0 && solar.kWp.isFinite, 'solar.kWp', solar.kWp);
    final pr = solar.performanceRatio;
    if (pr != null) _check(pr > 0 && pr <= 1, 'solar.performanceRatio', pr);
    _check(site.lat >= -90 && site.lat <= 90, 'site.lat', site.lat);
    _check(site.lon >= -180 && site.lon <= 180, 'site.lon', site.lon);
    _check(hours.isNotEmpty, 'hours', hours);
    for (final h in hours) {
      _check(h.irradianceWm2 >= 0, 'irradianceWm2', h.irradianceWm2);
    }
    _check(loadW >= 0 && loadW.isFinite, 'loadW', loadW);
  }

  static void _check(bool ok, String name, Object value) {
    if (!ok) throw ArgumentError.value(value, name);
  }
}
