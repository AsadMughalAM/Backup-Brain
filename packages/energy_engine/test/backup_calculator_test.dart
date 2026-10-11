import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

import 'fixtures/demo_household.dart';

const _calc = BackupCalculator();

// 12 V × 200 Ah × 2 = 4800 Wh on a UPS (efficiency 0.85).
BackupInput _bank(
  BatteryChemistry chemistry, {
  double soc = 0.8,
  double health = 1.0,
  double? minSoc,
  double? efficiency,
}) => BackupInput(
  battery: BatterySpec(
    chemistry: chemistry,
    voltage: 12,
    ampHours: 200,
    count: 2,
    minSoc: minSoc,
  ),
  inverter: InverterSpec(
    type: InverterType.ups,
    ratedW: 1500,
    efficiency: efficiency,
  ),
  socNow: soc,
  healthFactor: health,
);

void main() {
  group('normal case', () {
    test('lead-acid: 4800 Wh × (0.8 − 0.5) × 0.85 / 300 W', () {
      final e = _calc.estimate(_bank(BatteryChemistry.leadAcid), loadW: 300);
      expect(e.usableWh, closeTo(1440, 1e-9));
      expect(e.hours, closeTo(4.08, 1e-9));
      expect(e.minSoc, 0.5);
      expect(e.isOverloaded, isFalse);
      expect(e.isDerated, isFalse);
    });

    test('demo household gives 3 h 28 min at 420 W (ARCHITECTURE §12)', () {
      final e = _calc.estimate(demoInput, loadW: 420);
      // 3600 Wh × (0.60 − 0.15) × 0.90 / 420 W
      expect(e.hours, closeTo(1458 / 420, 1e-9));
      expect((e.hours * 60).floor(), 3 * 60 + 28);
    });

    test('health factor scales usable energy', () {
      final e = _calc.estimate(
        _bank(BatteryChemistry.leadAcid, health: 0.8),
        loadW: 300,
      );
      expect(e.hours, closeTo(1440 * 0.8 * 0.85 / 300, 1e-9));
    });

    test('minSoc and efficiency overrides beat the defaults', () {
      final e = _calc.estimate(
        _bank(BatteryChemistry.leadAcid, minSoc: 0.3, efficiency: 0.95),
        loadW: 300,
      );
      expect(e.minSoc, 0.3);
      expect(e.hours, closeTo(4800 * 0.5 * 0.95 / 300, 1e-9));
    });

    test('load above inverter rating is flagged as overload', () {
      final e = _calc.estimate(demoInput, loadW: 2170);
      expect(e.isOverloaded, isTrue);
      expect(e.hours, greaterThan(0));
    });
  });

  group('zero load', () {
    test('backup is unlimited', () {
      final e = _calc.estimate(_bank(BatteryChemistry.leadAcid), loadW: 0);
      expect(e.isUnlimited, isTrue);
      expect(e.isOverloaded, isFalse);
    });
  });

  group('SoC at or below minimum', () {
    test('at minimum gives zero hours', () {
      final e = _calc.estimate(
        _bank(BatteryChemistry.leadAcid, soc: 0.5),
        loadW: 300,
      );
      expect(e.hours, 0);
      expect(e.usableWh, 0);
    });

    test('below minimum is clamped to zero, never negative', () {
      final e = _calc.estimate(
        _bank(BatteryChemistry.tubular, soc: 0.3),
        loadW: 300,
      );
      expect(e.hours, 0);
    });

    test('LiFePO4 at 30% still has energy (min 15%)', () {
      final e = _calc.estimate(
        _bank(BatteryChemistry.lifepo4, soc: 0.3),
        loadW: 300,
      );
      expect(e.hours, closeTo(4800 * 0.15 * 0.85 / 300, 1e-9));
    });
  });

  group('lead-acid vs LiFePO4', () {
    test('same bank and SoC: LiFePO4 lasts longer (deeper usable range)', () {
      final lead = _calc.estimate(_bank(BatteryChemistry.leadAcid), loadW: 300);
      final lfp = _calc.estimate(_bank(BatteryChemistry.lifepo4), loadW: 300);
      expect(lfp.hours, closeTo(8.84, 1e-9));
      expect(lfp.hours, greaterThan(lead.hours));
    });

    test('high load (> 0.2C) derates lead-acid by 0.85', () {
      // 0.2 × 4800 Wh = 960 W threshold.
      final e = _calc.estimate(_bank(BatteryChemistry.leadAcid), loadW: 1000);
      expect(e.isDerated, isTrue);
      expect(e.hours, closeTo(1224 / 1000 * 0.85, 1e-9));
    });

    test('LiFePO4 is never derated', () {
      final e = _calc.estimate(_bank(BatteryChemistry.lifepo4), loadW: 1000);
      expect(e.isDerated, isFalse);
    });

    test('load exactly at 0.2C is not derated', () {
      final e = _calc.estimate(_bank(BatteryChemistry.leadAcid), loadW: 960);
      expect(e.isDerated, isFalse);
    });
  });

  group('invalid input', () {
    void expectInvalid(BackupInput input, {double loadW = 300}) =>
        expect(() => _calc.estimate(input, loadW: loadW), throwsArgumentError);

    test('negative, NaN or infinite load', () {
      final ok = _bank(BatteryChemistry.leadAcid);
      expectInvalid(ok, loadW: -1);
      expectInvalid(ok, loadW: double.nan);
      expectInvalid(ok, loadW: double.infinity);
    });

    test('SoC outside 0–1', () {
      expectInvalid(_bank(BatteryChemistry.leadAcid, soc: 1.2));
      expectInvalid(_bank(BatteryChemistry.leadAcid, soc: -0.1));
    });

    test('health factor outside (0, 1]', () {
      expectInvalid(_bank(BatteryChemistry.leadAcid, health: 0));
      expectInvalid(_bank(BatteryChemistry.leadAcid, health: 1.1));
    });

    test('bad battery, minSoc or efficiency', () {
      expectInvalid(
        const BackupInput(
          battery: BatterySpec(
            chemistry: BatteryChemistry.leadAcid,
            voltage: 0,
            ampHours: 100,
          ),
          inverter: InverterSpec(type: InverterType.ups, ratedW: 1000),
          socNow: 0.8,
        ),
      );
      expectInvalid(
        const BackupInput(
          battery: BatterySpec(
            chemistry: BatteryChemistry.leadAcid,
            voltage: 12,
            ampHours: 100,
            count: 0,
          ),
          inverter: InverterSpec(type: InverterType.ups, ratedW: 1000),
          socNow: 0.8,
        ),
      );
      expectInvalid(_bank(BatteryChemistry.leadAcid, minSoc: 1.5));
      expectInvalid(_bank(BatteryChemistry.leadAcid, efficiency: 1.1));
    });
  });
}
