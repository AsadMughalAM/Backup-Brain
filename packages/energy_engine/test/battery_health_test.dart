import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

/// The §12 demo bank: 24 V 150 Ah LiFePO4 = 3600 Wh, cutoff 15%.
const battery = BatterySpec(
  chemistry: BatteryChemistry.lifepo4,
  voltage: 24,
  ampHours: 150,
);
const inverter = InverterSpec(
  type: InverterType.hybrid,
  ratedW: 2000,
  efficiency: 0.9,
);

/// An outage on a battery that really holds [capacityWh]: 420 W for
/// [hours] from [start].
DischargeSession outage(
  double capacityWh, {
  double hours = 1.5,
  double start = 0.9,
  double loadW = 420,
}) => DischargeSession(
  startSoc: start,
  endSoc: start - loadW * hours / 0.9 / capacityWh,
  avgLoadW: loadW,
  hours: hours,
);

void main() {
  const monitor = BatteryHealthMonitor();

  test('fewer than three readings: no verdict yet', () {
    expect(
      monitor.assess(battery, inverter, [outage(3600), outage(3600)]),
      isNull,
    );
  });

  test('a new battery reads 100% and no warnings', () {
    final h = monitor.assess(battery, inverter, [
      for (var i = 0; i < 3; i++) outage(3600),
    ])!;
    expect(h.healthFactor, closeTo(1.0, 1e-9));
    expect(h.capacityWh, closeTo(3600, 1e-6));
    expect(h.warnings, isEmpty);
  });

  test(
    'capacity = load × hours / inverter_eff / ΔSoC; health = median / nominal',
    () {
      final h = monitor.assess(battery, inverter, [
        outage(2880),
        outage(2700),
        outage(3000),
      ])!;
      // Median 2880 Wh of 3600 = 80%: 20% lost → warning.
      expect(h.healthFactor, closeTo(0.8, 1e-9));
      expect(h.capacityLoss, closeTo(0.2, 1e-9));
      expect(h.warnings, contains(HealthWarning.capacityLoss));
    },
  );

  test('one bad reading does not swing the median', () {
    final h = monitor.assess(battery, inverter, [
      outage(3600),
      outage(1200),
      outage(3600),
    ])!;
    expect(h.healthFactor, closeTo(1.0, 1e-9));
  });

  test('small drops are ignored as reading error', () {
    final h = monitor.assess(battery, inverter, [
      outage(3600, hours: 0.25), // 3% drop
      outage(3600),
      outage(3600),
    ]);
    expect(h, isNull);
  });

  test('with enough history, loss is measured against the first readings', () {
    // Started at 90% of the label (a used battery), now at 72%: 20% lost.
    final h = monitor.assess(battery, inverter, [
      for (var i = 0; i < 3; i++) outage(3240),
      for (var i = 0; i < 7; i++) outage(2592),
    ])!;
    expect(h.healthFactor, closeTo(0.72, 1e-9));
    expect(h.capacityLoss, closeTo(0.2, 1e-9));
  });

  test('often drained below the cutoff: deep-discharge warning', () {
    final h = monitor.assess(battery, inverter, [
      outage(3600, start: 0.5, hours: 3), // ends at 11%
      outage(3600, start: 0.5, hours: 3),
      outage(3600),
    ])!;
    expect(h.warnings, contains(HealthWarning.deepDischarge));
  });
}
