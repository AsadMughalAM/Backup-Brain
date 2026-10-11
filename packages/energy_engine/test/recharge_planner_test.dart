import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

/// The §12 demo household: 24 V 150 Ah LiFePO4 (3600 Wh), hybrid 2 kW, 60%.
const demo = BackupInput(
  battery: BatterySpec(
    chemistry: BatteryChemistry.lifepo4,
    voltage: 24,
    ampHours: 150,
  ),
  inverter: InverterSpec(
    type: InverterType.hybrid,
    ratedW: 2000,
    efficiency: 0.9,
  ),
  socNow: 0.6,
);

void main() {
  const planner = RechargePlanner();

  test('unknown charger: C/10 of the bank', () {
    expect(planner.chargerW(demo), closeTo(360, 1e-9));
  });

  test(
    'hours to full: (target_Wh − current_Wh) / (charger_W × charge_eff)',
    () {
      // 0.4 × 3600 Wh / (360 W × 0.90) = 4.44 h
      expect(planner.hoursToFull(demo), closeTo(1440 / 324, 1e-9));
      expect(
        planner.hoursToFull(
          const BackupInput(
            battery: BatterySpec(
              chemistry: BatteryChemistry.lifepo4,
              voltage: 24,
              ampHours: 150,
            ),
            inverter: InverterSpec(
              type: InverterType.hybrid,
              ratedW: 2000,
              chargerW: 720,
            ),
            socNow: 0.6,
          ),
        ),
        closeTo(1440 / 648, 1e-9),
      );
    },
  );

  test('charging never goes past full', () {
    expect(planner.socAfterCharging(demo, 2), closeTo(0.6 + 648 / 3600, 1e-9));
    expect(planner.socAfterCharging(demo, 10), 1.0);
  });

  test('discharge is F1 in reverse and stops at the cutoff', () {
    // 420 W for 1 h = 466.7 Wh from the battery = 12.96% of 3600 Wh.
    expect(
      planner.socAfterDischarge(demo, loadW: 420, hours: 1),
      closeTo(0.6 - 420 / 0.9 / 3600, 1e-9),
    );
    expect(planner.socAfterDischarge(demo, loadW: 420, hours: 10), 0.15);
    expect(planner.socAfterDischarge(demo, loadW: 0, hours: 5), 0.6);
  });

  test('readiness: two hours of grid before a 1.5 h outage at 420 W', () {
    final r = planner.readiness(
      demo,
      loadW: 420,
      hoursUntil: 2,
      outageHours: 1.5,
    );
    expect(r.socAtStart, closeTo(0.78, 1e-9));
    // (0.78 − 0.15) × 3600 × 0.9 / 420 = 4.86 h
    expect(r.backup.hours, closeTo(0.63 * 3600 * 0.9 / 420, 1e-9));
    expect(r.coversOutage, isTrue);
    expect(r.fullByThen, isFalse);
  });

  test('readiness without a known outage length can not judge coverage', () {
    final r = planner.readiness(demo, loadW: 420, hoursUntil: 1);
    expect(r.coversOutage, isNull);
  });
}
