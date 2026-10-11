import 'package:energy_engine/energy_engine.dart';

/// Real Open-Meteo forecast for Lahore, fetched 11 Oct 2026 (PKT, UTC+5):
/// a hazy, cloudy day followed by a clearer one. Values are hourly means
/// for the hour ending at each timestamp.
const lahore = SiteLocation(lat: 31.5204, lon: 74.3587);

/// 2 × 24 hours, starting at local midnight on 11 Oct.
final _firstHourEnd = DateTime.fromMillisecondsSinceEpoch(
  1791658800 * 1000,
  isUtc: true,
);

const _irradiance = <double>[
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  15,
  70,
  76,
  203,
  339,
  328,
  506,
  497,
  389,
  268,
  115,
  11,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  36,
  173,
  344,
  501,
  612,
  666,
  655,
  581,
  451,
  285,
  117,
  11,
  0,
  0,
  0,
  0,
  0,
];

const _airTemp = <double>[
  22.3,
  22.6,
  22.5,
  22.5,
  21.7,
  22.2,
  22.1,
  22.2,
  22.7,
  20.6,
  22.3,
  25.2,
  25.1,
  25.2,
  25.4,
  25.2,
  24.7,
  23.8,
  22.7,
  22.1,
  21.6,
  21.2,
  20.7,
  20.4,
  20.1,
  19.9,
  19.7,
  19.4,
  19.2,
  19,
  18.8,
  19.5,
  21.2,
  23.4,
  25.2,
  26.5,
  27.4,
  28,
  28.3,
  28.2,
  28,
  27.2,
  25.5,
  24.6,
  23.9,
  23.2,
  22.9,
  22.2,
];

List<HourlyWeather> _day(int index) => [
  for (var i = index * 24; i < (index + 1) * 24; i++)
    HourlyWeather(
      endsAt: _firstHourEnd.add(Duration(hours: i)),
      irradianceWm2: _irradiance[i],
      airTempC: _airTemp[i],
    ),
];

final lahoreToday = _day(0);
final lahoreTomorrow = _day(1);

/// 08:00 PKT on the first day.
final lahoreMorning = DateTime.utc(2026, 10, 11, 3);
