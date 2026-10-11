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

  test('hours to full: (target_Wh − current_Wh) / (charger_W × charge_eff), '
      'the last 5% of LiFePO4 at half rate', () {
    // 60→95%: 1260 Wh / 324 W = 3.89 h; 95→100%: 180 Wh / 162 W = 1.11 h.
    expect(planner.hoursToFull(demo), closeTo(1260 / 324 + 180 / 162, 1e-9));
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
      closeTo(1260 / 648 + 180 / 324, 1e-9),
    );
  });

  test('lead-acid tapers from 80%: the last fifth takes as long as the '
      'first two fifths', () {
    const tubular = BackupInput(
      battery: BatterySpec(
        chemistry: BatteryChemistry.tubular,
        voltage: 12,
        ampHours: 200,
        count: 2,
      ),
      inverter: InverterSpec(type: InverterType.ups, ratedW: 1200),
      socNow: 0.4,
    );
    // C/10 = 480 W × 0.80 = 384 W into 4800 Wh: 8% an hour, 4% above 80%.
    expect(planner.hoursToFull(tubular), closeTo(5 + 5, 1e-9));
    expect(planner.socAfterCharging(tubular, 5), closeTo(0.8, 1e-9));
    expect(planner.socAfterCharging(tubular, 7.5), closeTo(0.9, 1e-9));
    expect(planner.socAfterCharging(tubular, 20), 1.0);
  });

  test('already full: no charging time, no change', () {
    final full = BackupInput(
      battery: demo.battery,
      inverter: demo.inverter,
      socNow: 1,
    );
    expect(planner.hoursToFull(full), 0);
    expect(planner.socAfterCharging(full, 3), 1.0);
  });

  test('negative charging time is rejected', () {
    expect(() => planner.socAfterCharging(demo, -1), throwsArgumentError);
  });

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
