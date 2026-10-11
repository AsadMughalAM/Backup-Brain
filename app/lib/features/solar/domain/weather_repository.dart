import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/weather_forecast.dart';

abstract interface class WeatherRepository {
  /// The newest saved forecast, from the offline cache first; null when
  /// none has been fetched yet or the user is signed out.
  Stream<WeatherForecast?> watchLatest();

  /// Fetches a fresh forecast for [site] and saves it. Throws when the
  /// weather service can't be reached.
  Future<void> refresh(SiteLocation site);
}

/// Bound to the Open-Meteo + Firestore implementation in
/// `app/app_providers.dart`.
final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final latestForecastProvider = StreamProvider<WeatherForecast?>(
  (ref) => ref.watch(weatherRepositoryProvider).watchLatest(),
);
