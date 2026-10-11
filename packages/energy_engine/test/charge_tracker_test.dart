import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

/// The §12 demo household: 24 V 150 Ah LiFePO4 (3600 Wh), hybrid 2 kW.
BackupInput _lithium(double soc) => BackupInput(
  battery: const BatterySpec(
    chemistry: BatteryChemistry.lifepo4,
    voltage: 24,
    ampHours: 150,
  ),
  inverter: const InverterSpec(
    type: InverterType.hybrid,
    ratedW: 2000,
    efficiency: 0.9,
  ),
  socNow: soc,
);

/// Two 12 V 200 Ah tubular batteries (4800 Wh) on a 1200 W UPS.
BackupInput _tubular(double soc) => BackupInput(
  battery: const BatterySpec(
    chemistry: BatteryChemistry.tubular,
    voltage: 12,
    ampHours: 200,
    count: 2,
  ),
  inverter: const InverterSpec(type: InverterType.ups, ratedW: 1200),
  socNow: soc,
);

void main() {
  const tracker = ChargeTracker();

  group('normal case', () {
    test('power cut: drains at the load, F1 in reverse', () {
      // 420 W for 1 h = 466.7 Wh from 3600 Wh: 60% → 47%.
      expect(
        tracker.socAfter(_lithium(0.6), gridOn: false, loadW: 420, hours: 1),
        closeTo(0.6 - 420 / 0.9 / 3600, 1e-9),
      );
    });

    test('power on: the charger fills it, whatever the house draws', () {
      // C/10 = 360 W × 0.90 = 9% an hour.
      expect(
        tracker.socAfter(_lithium(0.6), gridOn: true, loadW: 420, hours: 2),
        closeTo(0.78, 1e-9),
      );
    });

    test('grid time alone stops short of full', () {
      expect(
        tracker.socAfter(_lithium(0.6), gridOn: true, loadW: 420, hours: 24),
        EngineDefaults.estimatedChargeCap,
      );
    });

    test('a full reading stays full while the grid is on', () {
      expect(
        tracker.socAfter(_lithium(1), gridOn: true, loadW: 420, hours: 5),
        1.0,
      );
    });

    test('no time passed: the known charge', () {
      expect(
        tracker.socAfter(_lithium(0.6), gridOn: false, loadW: 420, hours: 0),
        0.6,
      );
    });
  });

  group('zero load', () {
    test('nothing on during a cut: the charge holds', () {
      expect(
        tracker.socAfter(_lithium(0.6), gridOn: false, loadW: 0, hours: 3),
        0.6,
      );
    });
  });

  group('SoC at or below the minimum', () {
    test('a cut never drains past the cutoff', () {
      expect(
        tracker.socAfter(_lithium(0.6), gridOn: false, loadW: 420, hours: 12),
        0.15,
      );
    });

    test('already below the cutoff: stays where it was', () {
      expect(
        tracker.socAfter(_tubular(0.4), gridOn: false, loadW: 300, hours: 2),
        0.4,
      );
    });

    test('below the cutoff, the grid still charges it', () {
      // 384 W into 4800 Wh = 8% an hour.
      expect(
        tracker.socAfter(_tubular(0.4), gridOn: true, loadW: 300, hours: 1),
        closeTo(0.48, 1e-9),
      );
    });
  });

  group('lead-acid vs LiFePO4', () {
    test('lead-acid slows above 80%; LiFePO4 keeps the full rate', () {
      // Tubular: 8%/h to 80% (1.25 h), then 4%/h. LiFePO4: 9%/h to 95%.
      expect(
        tracker.socAfter(_tubular(0.7), gridOn: true, loadW: 0, hours: 2.5),
        closeTo(0.85, 1e-9),
      );
      expect(
        tracker.socAfter(_lithium(0.7), gridOn: true, loadW: 0, hours: 2.5),
        closeTo(0.925, 1e-9),
      );
    });

    test('lead-acid at a heavy load drains faster (Peukert derate)', () {
      // 1100 W > 0.2 × 4800 Wh: 85% of the plain backup time.
      final derated = tracker.socAfter(
        _tubular(1),
        gridOn: false,
        loadW: 1100,
        hours: 1,
      );
      const plainHoursTo50 = 0.5 * 4800 * 0.85 / 1100;
      expect(derated, closeTo(1 - 0.5 / (plainHoursTo50 * 0.85), 1e-9));
    });
  });

  group('when to ask the user', () {
    test('never read, or read long ago: ask', () {
      expect(tracker.needsCheck(hoursSinceCheck: null), isTrue);
      expect(tracker.needsCheck(hoursSinceCheck: 6), isTrue);
    });

    test('read recently: don\'t ask again', () {
      expect(tracker.needsCheck(hoursSinceCheck: 1), isFalse);
    });
  });

  group('invalid input', () {
    test('negative time, charge above full and negative load are rejected', () {
      expect(
        () => tracker.socAfter(
          _lithium(0.6),
          gridOn: false,
          loadW: 420,
          hours: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => tracker.socAfter(
          _lithium(0.6),
          gridOn: true,
          loadW: 420,
          hours: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => tracker.socAfter(_lithium(1.2), gridOn: true, loadW: 0, hours: 1),
        throwsArgumentError,
      );
      expect(
        () =>
            tracker.socAfter(_lithium(0.6), gridOn: false, loadW: -5, hours: 1),
        throwsArgumentError,
      );
    });
  });
}
