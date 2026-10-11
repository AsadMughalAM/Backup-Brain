import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energy_engine/energy_engine.dart';

import '../../domain/entities/weather_forecast.dart';

/// Reads Open-Meteo's JSON and the trimmed copy saved in `weatherCache`
/// (TECH_STACK.md §4). Hourly values are parallel arrays in both.
abstract final class WeatherDto {
  static WeatherForecast fromOpenMeteo(
    Map<String, dynamic> json, {
    required SiteLocation site,
    required DateTime fetchedAt,
  }) {
    final hourly = json['hourly'] as Map<String, dynamic>;
    return _forecast(
      site: site,
      fetchedAt: fetchedAt,
      utcOffsetSeconds: json['utc_offset_seconds'],
      endsAt: hourly['time'],
      irradiance: hourly['shortwave_radiation'],
      airTemp: hourly['temperature_2m'],
    );
  }

  static WeatherForecast fromMap(Map<String, dynamic> map) => _forecast(
    site: SiteLocation(
      lat: (map['lat'] as num).toDouble(),
      lon: (map['lon'] as num).toDouble(),
    ),
    fetchedAt: (map['fetchedAt'] as Timestamp).toDate().toUtc(),
    utcOffsetSeconds: map['utcOffsetSeconds'],
    endsAt: map['endsAt'],
    irradiance: map['irradiance'],
    airTemp: map['airTemp'],
  );

  static Map<String, dynamic> toMap(WeatherForecast f) => {
    'lat': f.site.lat,
    'lon': f.site.lon,
    'fetchedAt': Timestamp.fromDate(f.fetchedAt),
    'utcOffsetSeconds': f.utcOffset.inSeconds,
    'endsAt': [
      for (final h in f.hours) h.endsAt.millisecondsSinceEpoch ~/ 1000,
    ],
    'irradiance': [for (final h in f.hours) h.irradianceWm2],
    'airTemp': [for (final h in f.hours) h.airTempC],
  };

  /// Cache document id: the location's local date of the fetch, so the
  /// collection keeps one forecast per day.
  static String docId(WeatherForecast f) {
    final local = f.fetchedAt.add(f.utcOffset);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  static WeatherForecast _forecast({
    required SiteLocation site,
    required DateTime fetchedAt,
    required Object? utcOffsetSeconds,
    required Object? endsAt,
    required Object? irradiance,
    required Object? airTemp,
  }) {
    final times = (endsAt as List).cast<num>();
    final ghi = (irradiance as List).cast<num?>();
    final temp = (airTemp as List).cast<num?>();
    if (ghi.length != times.length || temp.length != times.length) {
      throw const FormatException('Hourly arrays differ in length');
    }
    return WeatherForecast(
      site: site,
      fetchedAt: fetchedAt,
      utcOffset: Duration(seconds: (utcOffsetSeconds as num).toInt()),
      hours: [
        for (var i = 0; i < times.length; i++)
          HourlyWeather(
            endsAt: DateTime.fromMillisecondsSinceEpoch(
              times[i].toInt() * 1000,
              isUtc: true,
            ),
            // Open-Meteo sends null for hours without model data; treat
            // them as no sun rather than failing the whole forecast.
            irradianceWm2: (ghi[i] ?? 0).toDouble(),
            airTempC: (temp[i] ?? 0).toDouble(),
          ),
      ],
    );
  }
}
