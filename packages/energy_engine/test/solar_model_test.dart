import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

import 'fixtures/demo_household.dart';
import 'fixtures/lahore_forecast.dart';

const _model = SolarModel();

/// The demo household's 4 × 540 W panels.
const _panels = SolarSpec(kWp: 2.16);

BackupInput _battery(double soc, {BatteryChemistry? chemistry}) => BackupInput(
  battery: BatterySpec(
    chemistry: chemistry ?? demoInput.battery.chemistry,
    voltage: demoInput.battery.voltage,
    ampHours: demoInput.battery.ampHours,
  ),
  inverter: demoInput.inverter,
  socNow: soc,
);

SolarDayForecast _today({
  SolarSpec solar = _panels,
  double soc = 0.6,
  double loadW = 420,
  DateTime? from,
  BatteryChemistry? chemistry,
}) => _model.forecastDay(
  solar: solar,
  site: lahore,
  hours: lahoreToday,
  battery: _battery(soc, chemistry: chemistry),
  loadW: loadW,
  from: from ?? lahoreMorning,
);

SolarDayForecast _tomorrowFromCutoff() => _model.forecastDay(
  solar: _panels,
  site: lahore,
  hours: lahoreTomorrow,
  battery: _battery(demoInput.battery.cutoffSoc),
  loadW: 420,
);

/// PKT wall-clock hour, for readable expectations.
double _pkt(DateTime utc) {
  final local = utc.add(const Duration(hours: 5));
  return local.hour + local.minute / 60;
}

void main() {
  group('sun position', () {
    test('Lahore, 11 Oct: sunrise ~6:05 AM and sunset ~5:35 PM PKT', () {
      final day = SolarGeometry.daylight(lahore, DateTime.utc(2026, 10, 11, 7));
      expect(_pkt(day.sunrise), closeTo(6.08, 0.15));
      expect(_pkt(day.sunset), closeTo(17.6, 0.15));
    });

    test('no clear-sky irradiance at night', () {
      final midnight = DateTime.utc(2026, 10, 11, 19);
      expect(SolarGeometry.clearSkyIrradiance(lahore, midnight), 0);
    });

    test(
      'clear-sky noon irradiance is in the realistic 700–1000 W/m² band',
      () {
        final noon = DateTime.utc(2026, 10, 11, 7);
        expect(
          SolarGeometry.clearSkyIrradiance(lahore, noon),
          inInclusiveRange(700, 1000),
        );
      },
    );
  });

  group('normal case (demo household, real Lahore forecast)', () {
    test('cloudy today: about half the sun of a clear day', () {
      final f = _today();
      expect(f.expectedKWh, closeTo(3.93, 0.01));
      expect(f.belowClearSky, closeTo(0.49, 0.01));
      expect(f.lowKWh, lessThan(f.expectedKWh));
      expect(f.highKWh, greaterThan(f.expectedKWh));
    });

    test('battery climbs from 60% to ~79% by sunset, not full', () {
      final f = _today();
      expect(f.startSoc, 0.6);
      expect(f.socAtSunset, closeTo(0.79, 0.01));
      expect(f.fullAt, isNull);
      expect(f.sunIsOver, isFalse);
    });

    test('night backup at 420 W runs out before sunrise', () {
      final f = _today();
      expect(f.night.hours, closeTo(4.96, 0.01));
      expect(
        f.nightEndsAt!.difference(f.sunset).inMinutes,
        (f.night.hours * 60).floor(),
      );
      expect(f.lastsUntilSunrise, isFalse);
    });

    test('sunniest 3 hours are 12–3 PM PKT', () {
      final window = _today().peakWindow!;
      expect(_pkt(window.start), 12);
      expect(_pkt(window.end), 15);
    });

    test('clearer tomorrow, from the cutoff: reaches ~73% (demo step 4)', () {
      final f = _tomorrowFromCutoff();
      expect(f.startSoc, 0.15);
      expect(f.belowClearSky, closeTo(0.19, 0.01));
      expect(f.socAtSunset, closeTo(0.73, 0.01));
    });

    test('bigger array fills the battery and says when', () {
      final f = _today(solar: const SolarSpec(kWp: 5));
      expect(f.socAtSunset, 1);
      expect(_pkt(f.fullAt!), inInclusiveRange(10, 14));
    });

    test('hours are daylight only, sunrise to sunset', () {
      final f = _today();
      expect(f.hours, hasLength(12));
      expect(f.hours.every((h) => h.expectedWh >= 0), isTrue);
    });
  });

  group('derates', () {
    test('heavy shading cuts generation to 65%', () {
      final shaded = _today(
        solar: const SolarSpec(kWp: 2.16, shading: PanelShading.heavy),
      );
      expect(shaded.expectedKWh, closeTo(_today().expectedKWh * 0.65, 1e-9));
      // Weather, not the panels, sets the "vs. a clear day" figure.
      expect(shaded.belowClearSky, closeTo(_today().belowClearSky, 1e-9));
    });

    test('panels cleaned this week skip the 0.90 dust factor', () {
      final clean = _today(
        solar: SolarSpec(kWp: 2.16, lastCleanedAt: DateTime.utc(2026, 10, 9)),
      );
      expect(clean.expectedKWh, closeTo(_today().expectedKWh / 0.90, 1e-9));
    });
  });

  group('zero load', () {
    test('all solar charges the battery and the night is unlimited', () {
      final f = _today(loadW: 0);
      expect(f.socAtSunset, greaterThan(_today().socAtSunset));
      expect(f.night.isUnlimited, isTrue);
      expect(f.nightEndsAt, isNull);
      expect(f.lastsUntilSunrise, isTrue);
    });
  });

  group('SoC at or below minimum', () {
    test('starting at the cutoff, solar still charges it', () {
      final f = _today(soc: demoInput.battery.cutoffSoc);
      expect(f.socAtSunset, greaterThan(demoInput.battery.cutoffSoc));
    });

    test('after sunset: no more charging; the night counts from now', () {
      final evening = DateTime.utc(2026, 10, 11, 15); // 8 PM PKT
      final f = _today(soc: 0.15, from: evening);
      expect(f.sunIsOver, isTrue);
      expect(f.socAtSunset, 0.15);
      expect(f.night.hours, 0);
      expect(f.nightEndsAt, evening);
      expect(f.peakWindow, isNull);
    });
  });

  group('lead-acid vs LiFePO4', () {
    test('lead-acid charges less from the same sun (0.80 vs 0.90)', () {
      final lithium = _today();
      final lead = _today(chemistry: BatteryChemistry.tubular);
      final lithiumGain = lithium.socAtSunset - 0.6;
      final leadGain = lead.socAtSunset - 0.6;
      expect(leadGain / lithiumGain, closeTo(0.80 / 0.90, 1e-9));
    });
  });

  group('invalid input', () {
    test(
      'rejects zero kWp, empty hours, bad coordinates and negative load',
      () {
        expect(
          () => _today(solar: const SolarSpec(kWp: 0)),
          throwsArgumentError,
        );
        expect(
          () => _model.forecastDay(
            solar: _panels,
            site: lahore,
            hours: const [],
            battery: _battery(0.6),
            loadW: 420,
          ),
          throwsArgumentError,
        );
        expect(
          () => _model.forecastDay(
            solar: _panels,
            site: const SiteLocation(lat: 95, lon: 74),
            hours: lahoreToday,
            battery: _battery(0.6),
            loadW: 420,
          ),
          throwsArgumentError,
        );
        expect(() => _today(loadW: -1), throwsArgumentError);
      },
    );
  });
}
