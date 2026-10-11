import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

final pricing = SolarPricing(
  panelW: 580,
  panelPricePerW: PriceRange(28, 36),
  ongridInverter: {
    3: PriceRange(100000, 150000),
    4: PriceRange(120000, 170000),
    6: PriceRange(160000, 230000),
  },
  hybridInverter: {
    3: PriceRange(140000, 200000),
    4: PriceRange(170000, 240000),
    6: PriceRange(230000, 330000),
  },
  batteryPerKWh: PriceRange(45000, 65000),
  installationPerKw: PriceRange(18000, 30000),
  tariffPerUnit: 55,
);

/// ARCHITECTURE §12 demo step 5: a Lahore neighbour using 400 units/month.
const lahore400 = SizingInput(
  monthlyKWh: 400,
  psh: 5.1,
  nightLoadW: 500,
  backupHours: 4,
);

void main() {
  const sizing = SolarSizing();
  final packages = sizing.packages(lahore400, pricing);
  final basic = packages[0], hybrid = packages[1], full = packages[2];

  test('three packages in order, the goal\'s one recommended', () {
    expect(packages.map((p) => p.kind), [
      PackageKind.basic,
      PackageKind.hybrid,
      PackageKind.fullBackup,
    ]);
    expect(
      packages.where((p) => p.recommended).single.kind,
      PackageKind.hybrid,
    );
    expect(
      sizing
          .packages(
            const SizingInput(
              monthlyKWh: 400,
              psh: 5.1,
              nightLoadW: 500,
              backupHours: 4,
              goal: SolarGoal.reduceBill,
            ),
            pricing,
          )
          .firstWhere((p) => p.recommended)
          .kind,
      PackageKind.basic,
    );
  });

  test('kWp = units / (30 × PSH × PR), rounded up to whole panels', () {
    // 400 / (30 × 5.1 × 0.78) = 3.35 kWp → 6 × 580 W = 3.48 kWp
    expect(basic.panelCount, 6);
    expect(basic.kWp, closeTo(3.48, 1e-9));
    expect(basic.inverterKw, 4, reason: 'smallest standard size ≥ 3.48 kW');
    expect(basic.hasBattery, isFalse);
  });

  test('savings cap at the units actually used', () {
    // 3.48 kWp × 5.1 × 0.78 × 30 = 415 kWh made, but only 400 are bought.
    expect(basic.monthlyKWh, closeTo(3.48 * 5.1 * 0.78 * 30, 1e-9));
    expect(basic.monthlySavings, 400 * 55);
  });

  test('cost is the sum of parts, as a range', () {
    expect(basic.cost.min, closeTo(28 * 3480 + 120000 + 18000 * 3.48, 1e-6));
    expect(basic.cost.max, closeTo(36 * 3480 + 170000 + 30000 * 3.48, 1e-6));
    expect(
      basic.paybackYears.min,
      closeTo(basic.cost.min / (22000 * 12), 1e-9),
    );
  });

  test(
    'hybrid battery = night load × hours / (DoD × inverter eff), in 0.5 kWh steps',
    () {
      // 500 W × 4 h / (0.85 × 0.90) = 2.61 kWh → 3.0 kWh
      expect(hybrid.batteryKWh, 3.0);
      expect(hybrid.panelCount, basic.panelCount);
      expect(
        hybrid.cost.min,
        closeTo(28 * 3480 + 170000 + 45000 * 3.0 + 18000 * 3.48, 1e-6),
      );
    },
  );

  test('full backup: a whole night of battery and panels to refill it', () {
    // 500 W × 10 h / 0.765 = 6.54 kWh → 7.0 kWh; refill 7 / (5.1 × 0.78 ×
    // 0.90) = 1.96 kWp; 3.35 + 1.96 = 5.31 kWp → 10 panels → 6 kW inverter.
    expect(full.batteryKWh, 7.0);
    expect(full.panelCount, 10);
    expect(full.inverterKw, 6);
  });

  test('a load beyond the largest inverter takes several', () {
    final big = sizing.packages(
      const SizingInput(
        monthlyKWh: 3000,
        psh: 5.1,
        nightLoadW: 500,
        backupHours: 4,
      ),
      pricing,
    );
    expect(big.first.inverterKw, 6);
    expect(big.first.inverterCount, greaterThan(1));
  });

  test('nonsense input is rejected', () {
    expect(
      () => sizing.packages(
        const SizingInput(monthlyKWh: 0, psh: 5, nightLoadW: 0, backupHours: 0),
        pricing,
      ),
      throwsArgumentError,
    );
  });
}
