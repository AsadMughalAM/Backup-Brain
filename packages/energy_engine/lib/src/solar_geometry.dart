import 'dart:math' as math;

import 'models/solar_spec.dart';

/// Sun position and clear-sky irradiance from date and place alone, so the
/// "vs. a clear day" baseline needs no extra data and works offline.
/// Cooper's declination, the Spencer-style equation of time and the
/// Haurwitz clear-sky model: accurate to a few minutes and a few percent,
/// which is plenty for a daily charge forecast.
abstract final class SolarGeometry {
  static const _haurwitzA = 1098.0;
  static const _haurwitzB = 0.057;

  /// The sun's upper edge touches the horizon at 90.833°: refraction and
  /// the solar disc's radius make the day ~10–15 min longer than at 90°.
  static const _sunsetZenithDeg = 90.833;

  /// Cosine of the solar zenith angle at [utc]; ≤ 0 when the sun is down.
  static double cosZenith(SiteLocation site, DateTime utc) {
    final (decl, eotMinutes) = _sun(utc);
    final lat = _rad(site.lat);
    final hourAngle = _rad(15 * (_solarTimeHours(site, utc, eotMinutes) - 12));
    return math.sin(lat) * math.sin(decl) +
        math.cos(lat) * math.cos(decl) * math.cos(hourAngle);
  }

  /// Global horizontal irradiance under a cloudless sky, W/m².
  static double clearSkyIrradiance(SiteLocation site, DateTime utc) {
    final cosZ = cosZenith(site, utc);
    if (cosZ <= 0) return 0;
    return _haurwitzA * cosZ * math.exp(-_haurwitzB / cosZ);
  }

  /// Sunrise and sunset (UTC) of the solar day containing [utc]. Polar day
  /// or night collapses to a 24 h or 0 h day around solar noon.
  static ({DateTime sunrise, DateTime sunset}) daylight(
    SiteLocation site,
    DateTime utc,
  ) {
    final (decl, eotMinutes) = _sun(utc);
    // Wrapped so "the solar day containing utc" is today's, not yesterday's.
    final solarTime = _solarTimeHours(site, utc, eotMinutes) % 24;
    final noon = utc.add(_hours(12 - solarTime));
    final lat = _rad(site.lat);
    final cosHalfDay =
        ((math.cos(_rad(_sunsetZenithDeg)) - math.sin(lat) * math.sin(decl)) /
                (math.cos(lat) * math.cos(decl)))
            .clamp(-1.0, 1.0);
    final halfDayHours = _deg(math.acos(cosHalfDay)) / 15;
    return (
      sunrise: noon.subtract(_hours(halfDayHours)),
      sunset: noon.add(_hours(halfDayHours)),
    );
  }

  /// (declination in radians, equation of time in minutes).
  static (double, double) _sun(DateTime utc) {
    final day = utc.difference(DateTime.utc(utc.year)).inDays + 1;
    final decl = _rad(23.45 * math.sin(2 * math.pi * (284 + day) / 365));
    final b = 2 * math.pi * (day - 81) / 364;
    final eot = 9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);
    return (decl, eot);
  }

  static double _solarTimeHours(
    SiteLocation site,
    DateTime utc,
    double eotMinutes,
  ) =>
      utc.hour +
      utc.minute / 60 +
      utc.second / 3600 +
      site.lon / 15 +
      eotMinutes / 60;

  static Duration _hours(double h) =>
      Duration(microseconds: (h * Duration.microsecondsPerHour).round());

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
}
