import 'package:dio/dio.dart';
import 'package:energy_engine/energy_engine.dart';

/// Open-Meteo forecast API: free and keyless, so the app calls it directly
/// (TECH_STACK.md §2). Returns the raw JSON for `WeatherDto`.
class OpenMeteoSource {
  OpenMeteoSource(this._dio);

  final Dio _dio;

  static const _url = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetchForecast(SiteLocation site) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _url,
      queryParameters: {
        'latitude': site.lat,
        'longitude': site.lon,
        'hourly': 'shortwave_radiation,temperature_2m',
        'forecast_days': 2,
        // F4 compares what the panels made with what each past day's
        // recorded weather should have given.
        'past_days': 7,
        // Epoch seconds avoid parsing local time strings; `auto` still
        // aligns the two days to the location's midnight.
        'timeformat': 'unixtime',
        'timezone': 'auto',
      },
    );
    return response.data ??
        (throw const FormatException('Empty Open-Meteo response'));
  }
}
