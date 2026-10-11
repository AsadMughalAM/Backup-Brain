import 'package:backup_brain/features/solar/data/models/weather_dto.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('WeatherDto', () {
    test('reads the real Open-Meteo response: 48 hours at UTC+5', () {
      final f = lahoreForecast();
      expect(f.hours, hasLength(48));
      expect(f.utcOffset, const Duration(hours: 5));
      // First value covers 23:00–00:00 PKT, i.e. ends at local midnight.
      expect(f.hours.first.endsAt, DateTime.utc(2026, 10, 10, 19));
      expect(f.hours[13].irradianceWm2, 506);
    });

    test('round-trips through the Firestore cache map', () {
      final f = lahoreForecast();
      final again = WeatherDto.fromMap(WeatherDto.toMap(f));
      expect(WeatherDto.toMap(again), WeatherDto.toMap(f));
      expect(again.fetchedAt, f.fetchedAt);
    });

    test('cache doc id is the local date of the fetch', () {
      // 00:30 PKT on 12 Oct is still 11 Oct in UTC.
      final f = lahoreForecast(fetchedAt: DateTime.utc(2026, 10, 11, 19, 30));
      expect(WeatherDto.docId(f), '2026-10-12');
    });

    test('missing hours read as no sun; ragged arrays fail loudly', () {
      final json = openMeteoLahoreJson();
      final hourly = json['hourly'] as Map<String, dynamic>;
      (hourly['shortwave_radiation'] as List)[12] = null;
      final f = WeatherDto.fromOpenMeteo(
        json,
        site: const SiteLocation(lat: 31.5, lon: 74.4),
        fetchedAt: lahoreMorning,
      );
      expect(f.hours[12].irradianceWm2, 0);

      (hourly['temperature_2m'] as List).removeLast();
      expect(
        () => WeatherDto.fromOpenMeteo(
          json,
          site: const SiteLocation(lat: 31.5, lon: 74.4),
          fetchedAt: lahoreMorning,
        ),
        throwsFormatException,
      );
    });
  });

  group('WeatherForecast', () {
    test('splits into local days', () {
      final f = lahoreForecast();
      final today = f.hoursOn(lahoreMorning);
      final tomorrow = f.hoursOn(lahoreMorning, dayOffset: 1);
      expect(today, hasLength(24));
      // The first value is the last hour of the 10th, so the 12th is one
      // hour short; both are night hours and don't change the forecast.
      expect(tomorrow, hasLength(23));
      expect(f.hoursOn(lahoreMorning, dayOffset: -1), hasLength(1));
    });

    test('fresh for an hour, and only for the same place', () {
      final f = lahoreForecast();
      const lahore = SiteLocation(lat: 31.52, lon: 74.36);
      expect(f.isFreshFor(lahore, lahoreMorning), isTrue);
      expect(
        f.isFreshFor(lahore, lahoreMorning.add(const Duration(hours: 1))),
        isFalse,
      );
      const karachi = SiteLocation(lat: 24.86, lon: 67.0);
      expect(f.isFreshFor(karachi, lahoreMorning), isFalse);
    });
  });
}
