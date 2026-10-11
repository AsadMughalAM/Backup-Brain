import 'package:energy_engine/energy_engine.dart';

/// A saved Open-Meteo forecast: hourly weather for today and tomorrow at
/// the household's location, plus when it was fetched (shown as its age).
class WeatherForecast {
  const WeatherForecast({
    required this.site,
    required this.fetchedAt,
    required this.utcOffset,
    required this.hours,
  });

  /// Open-Meteo asks for at most one fetch per location per hour
  /// (ARCHITECTURE.md §5 F3).
  static const maxAge = Duration(hours: 1);

  /// Coordinates that differ by less than this (~1 km) share a forecast.
  static const _sameSiteDegrees = 0.01;

  final SiteLocation site;
  final DateTime fetchedAt;

  /// The location's offset from UTC: "today" and every clock time shown
  /// are in the panels' local time, not the phone's.
  final Duration utcOffset;
  final List<HourlyWeather> hours;

  bool isFreshFor(SiteLocation other, DateTime now) =>
      now.difference(fetchedAt) < maxAge &&
      (site.lat - other.lat).abs() < _sameSiteDegrees &&
      (site.lon - other.lon).abs() < _sameSiteDegrees;

  /// The hours that start on the local calendar day of [utc] plus [dayOffset].
  List<HourlyWeather> hoursOn(DateTime utc, {int dayOffset = 0}) {
    final day = _localDay(utc).add(Duration(days: dayOffset));
    return [
      for (final h in hours)
        if (_localDay(h.startsAt) == day) h,
    ];
  }

  DateTime _localDay(DateTime utc) {
    final local = utc.add(utcOffset);
    return DateTime.utc(local.year, local.month, local.day);
  }
}
