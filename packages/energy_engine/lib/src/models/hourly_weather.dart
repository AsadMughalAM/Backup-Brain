/// One hour of forecast weather. Open-Meteo reports irradiance as the mean
/// over the hour *before* the timestamp, so the hour is identified by its
/// end.
final class HourlyWeather {
  const HourlyWeather({
    required this.endsAt,
    required this.irradianceWm2,
    required this.airTempC,
  });

  /// UTC.
  final DateTime endsAt;

  /// Global horizontal irradiance, W/m².
  final double irradianceWm2;
  final double airTempC;

  DateTime get startsAt => endsAt.subtract(const Duration(hours: 1));
}
