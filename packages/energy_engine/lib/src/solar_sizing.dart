import 'dart:math' as math;

import 'defaults.dart';
import 'models/battery_spec.dart';
import 'models/inverter_spec.dart';

/// A price as a market range, in PKR.
final class PriceRange {
  const PriceRange(this.min, this.max);

  final double min;
  final double max;

  static const zero = PriceRange(0, 0);

  PriceRange operator +(PriceRange other) =>
      PriceRange(min + other.min, max + other.max);

  PriceRange operator *(double k) => PriceRange(min * k, max * k);
}

/// Market prices for F5, from config (never hardcoded; ARCHITECTURE §5 F5).
final class SolarPricing {
  const SolarPricing({
    required this.panelW,
    required this.panelPricePerW,
    required this.ongridInverter,
    required this.hybridInverter,
    required this.batteryPerKWh,
    required this.installationPerKw,
    required this.tariffPerUnit,
  });

  /// The panel size quoted in packages, e.g. 580 W.
  final double panelW;
  final PriceRange panelPricePerW;

  /// Price per inverter by size in kW; the keys are the standard sizes.
  final Map<double, PriceRange> ongridInverter;
  final Map<double, PriceRange> hybridInverter;

  /// LiFePO4, the chemistry quoted for new systems.
  final PriceRange batteryPerKWh;

  /// Structure, wiring and labour, per kW of panels.
  final PriceRange installationPerKw;

  /// What a grid unit (kWh) costs the household, for savings.
  final double tariffPerUnit;
}

enum SolarGoal { reduceBill, backup, both }

enum PackageKind {
  /// On-grid, no battery: cuts the bill, no backup.
  basic,

  /// Bill sizing plus a battery for the user's backup hours.
  hybrid,

  /// A battery for a whole night, and extra panels to refill it daily.
  fullBackup,
}

final class SizingInput {
  const SizingInput({
    required this.monthlyKWh,
    required this.psh,
    required this.nightLoadW,
    required this.backupHours,
    this.peakLoadW,
    this.goal = SolarGoal.both,
  });

  /// Grid units used per month.
  final double monthlyKWh;

  /// Yearly average peak sun hours for the city.
  final double psh;

  /// What the house runs on battery at night.
  final double nightLoadW;
  final double backupHours;

  /// Highest load the inverter must carry; defaults to [nightLoadW].
  final double? peakLoadW;
  final SolarGoal goal;
}

final class SolarPackage {
  const SolarPackage({
    required this.kind,
    required this.panelCount,
    required this.panelW,
    required this.inverterKw,
    required this.inverterCount,
    required this.batteryKWh,
    required this.cost,
    required this.monthlyKWh,
    required this.monthlySavings,
    required this.recommended,
  });

  final PackageKind kind;
  final int panelCount;
  final double panelW;
  final double inverterKw;
  final int inverterCount;

  /// 0 for the on-grid package.
  final double batteryKWh;
  final PriceRange cost;

  /// Expected solar energy per month.
  final double monthlyKWh;

  /// Grid units no longer bought × tariff.
  final double monthlySavings;
  final bool recommended;

  double get kWp => panelCount * panelW / 1000;
  bool get hasBattery => batteryKWh > 0;

  /// Simple payback in years for the cheapest and dearest quote; infinite
  /// when there is nothing to save.
  PriceRange get paybackYears {
    final yearly = monthlySavings * 12;
    return yearly <= 0
        ? const PriceRange(double.infinity, double.infinity)
        : PriceRange(cost.min / yearly, cost.max / yearly);
  }
}

/// F5 — "Agar mein solar lagwana chahun to kitna kharcha aayega?"
/// (ARCHITECTURE.md §5 F5).
final class SolarSizing {
  const SolarSizing();

  /// Basic, Hybrid and Full backup, in that order; the one matching the
  /// goal is marked recommended.
  List<SolarPackage> packages(SizingInput input, SolarPricing pricing) {
    _validate(input, pricing);
    const pr = EngineDefaults.performanceRatio;
    const chemistry = BatteryChemistry.lifepo4;
    final usableDoD = 1 - EngineDefaults.minSoc(chemistry);
    final inverterEff = EngineDefaults.inverterEfficiency(InverterType.hybrid);

    // system_kWp = monthly_kWh / (30 × PSH × PR)
    final billKWp = input.monthlyKWh / (30 * input.psh * pr);

    // battery_Wh = night_load_W × backup_hours / (usable_DoD × inverter_eff)
    double batteryKWh(double hours) => _roundUp(
      input.nightLoadW * hours / (usableDoD * inverterEff) / 1000,
      EngineDefaults.batteryStepKWh,
    );

    final hybridBattery = batteryKWh(input.backupHours);
    final fullBattery = batteryKWh(
      math.max(input.backupHours, EngineDefaults.fullBackupHours),
    );
    // Extra panels so a day's sun refills the full-backup battery.
    final refillKWp =
        fullBattery /
        (input.psh * pr * EngineDefaults.chargeEfficiency(chemistry));

    final recommended = switch (input.goal) {
      SolarGoal.reduceBill => PackageKind.basic,
      SolarGoal.both => PackageKind.hybrid,
      SolarGoal.backup => PackageKind.fullBackup,
    };

    SolarPackage build(PackageKind kind, double kWp, double battery) {
      final panelCount = math.max(1, (kWp * 1000 / pricing.panelW).ceil());
      final actualKWp = panelCount * pricing.panelW / 1000;
      final hybrid = battery > 0;
      final peakKw = (input.peakLoadW ?? input.nightLoadW) / 1000;
      // inverter_kW = max(system_kWp, peak_load_kW × 1.25); an on-grid
      // inverter only carries the panels.
      final neededKw = hybrid
          ? math.max(actualKWp, peakKw * EngineDefaults.inverterHeadroom)
          : actualKWp;
      final table = hybrid ? pricing.hybridInverter : pricing.ongridInverter;
      final (size, count) = _inverter(neededKw, table.keys.toList()..sort());
      final production = actualKWp * input.psh * pr * 30;

      return SolarPackage(
        kind: kind,
        panelCount: panelCount,
        panelW: pricing.panelW,
        inverterKw: size,
        inverterCount: count,
        batteryKWh: battery,
        cost:
            pricing.panelPricePerW * (actualKWp * 1000) +
            table[size]! * count.toDouble() +
            pricing.batteryPerKWh * battery +
            pricing.installationPerKw * actualKWp,
        monthlyKWh: production,
        monthlySavings:
            math.min(production, input.monthlyKWh) * pricing.tariffPerUnit,
        recommended: kind == recommended,
      );
    }

    return [
      build(PackageKind.basic, billKWp, 0),
      build(PackageKind.hybrid, billKWp, hybridBattery),
      build(PackageKind.fullBackup, billKWp + refillKWp, fullBattery),
    ];
  }

  /// The smallest standard size that covers [kw]; above the largest, that
  /// size several times.
  static (double, int) _inverter(double kw, List<double> sizes) {
    for (final s in sizes) {
      if (s >= kw) return (s, 1);
    }
    final largest = sizes.last;
    return (largest, (kw / largest).ceil());
  }

  static double _roundUp(double v, double step) =>
      v <= 0 ? 0 : (v / step).ceil() * step;

  static void _validate(SizingInput input, SolarPricing pricing) {
    void check(bool ok, String name, Object value) {
      if (!ok) throw ArgumentError.value(value, name);
    }

    check(input.monthlyKWh > 0, 'monthlyKWh', input.monthlyKWh);
    check(input.psh > 0, 'psh', input.psh);
    check(input.nightLoadW >= 0, 'nightLoadW', input.nightLoadW);
    check(input.backupHours >= 0, 'backupHours', input.backupHours);
    check(pricing.panelW > 0, 'panelW', pricing.panelW);
    check(pricing.ongridInverter.isNotEmpty, 'ongridInverter', 'empty');
    check(pricing.hybridInverter.isNotEmpty, 'hybridInverter', 'empty');
  }
}
