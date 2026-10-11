import 'defaults.dart';
import 'models/battery_spec.dart';
import 'solar_sizing.dart';

enum BatterySymptom {
  swollen,
  smellOrHeat,
  wontCharge,

  /// Backup lasts minutes instead of hours.
  shortBackup,

  /// Tubular only: plates showing / water below the mark.
  lowWater,
}

enum BatteryVerdict {
  /// Disconnect now and call a technician (golden rule 8); nothing else.
  unsafe,

  /// Something the household can fix: water, a full charge, settings.
  tryMaintenance,

  /// Likely the charger, wiring or a cell: worth a repair shop's look.
  repairPossible,
  replace,

  /// No symptom picked.
  noIssue,
}

/// F7 step 1 — repair or replace (ARCHITECTURE.md §5 F7). Rules, not a
/// model: the same symptoms always give the same verdict.
final class BatteryDiagnosis {
  const BatteryDiagnosis();

  /// [healthFactor] from F6 when measured; it turns "short backup" into a
  /// replace verdict once the battery has lost most of its capacity.
  BatteryVerdict diagnose(
    Set<BatterySymptom> symptoms,
    BatteryChemistry chemistry, {
    double? healthFactor,
  }) {
    if (symptoms.contains(BatterySymptom.swollen) ||
        symptoms.contains(BatterySymptom.smellOrHeat)) {
      return BatteryVerdict.unsafe;
    }
    final worn =
        healthFactor != null &&
        healthFactor < EngineDefaults.replaceBelowHealth;
    if (worn &&
        (symptoms.contains(BatterySymptom.shortBackup) ||
            symptoms.contains(BatterySymptom.wontCharge))) {
      return BatteryVerdict.replace;
    }
    if (symptoms.contains(BatterySymptom.lowWater) &&
        chemistry == BatteryChemistry.tubular) {
      return BatteryVerdict.tryMaintenance;
    }
    if (symptoms.contains(BatterySymptom.wontCharge)) {
      return BatteryVerdict.repairPossible;
    }
    if (symptoms.contains(BatterySymptom.shortBackup)) {
      // Unmeasured: a full charge and the right charger setting fix this
      // often enough to try before spending.
      return BatteryVerdict.tryMaintenance;
    }
    return BatteryVerdict.noIssue;
  }
}

/// One kind of battery to compare, priced per kWh of label capacity.
final class BatteryOption {
  const BatteryOption({
    required this.id,
    required this.chemistry,
    required this.pricePerKWh,
    required this.cycleLife,
    required this.warrantyMonths,
  });

  final String id;
  final BatteryChemistry chemistry;
  final PriceRange pricePerKWh;

  /// Full cycles to end of life at the chemistry's safe depth.
  final int cycleLife;
  final int warrantyMonths;
}

final class RankedOption {
  const RankedOption({
    required this.option,
    required this.price,
    required this.lifeYears,
    required this.costPerUsableKWhYear,
  });

  final BatteryOption option;

  /// For a bank the size of the user's.
  final PriceRange price;
  final double lifeYears;

  /// `price ÷ (usable_kWh × expected_life_years)`, mid price — why lithium
  /// can be cheaper long-term despite the higher upfront cost.
  final double costPerUsableKWhYear;
}

/// F7 step 2 — which battery to buy, cheapest over its life first.
final class BatteryRanking {
  const BatteryRanking();

  List<RankedOption> rank(List<BatteryOption> options, double bankWh) {
    if (bankWh <= 0) throw ArgumentError.value(bankWh, 'bankWh');
    final kWh = bankWh / 1000;
    final ranked = [
      for (final o in options)
        () {
          final price = o.pricePerKWh * kWh;
          final usableKWh = kWh * (1 - EngineDefaults.minSoc(o.chemistry));
          // One deep cycle a day: daily load-shedding.
          final lifeYears = o.cycleLife / EngineDefaults.cyclesPerYear;
          return RankedOption(
            option: o,
            price: price,
            lifeYears: lifeYears,
            costPerUsableKWhYear:
                (price.min + price.max) / 2 / (usableKWh * lifeYears),
          );
        }(),
    ]..sort((a, b) => a.costPerUsableKWhYear.compareTo(b.costPerUsableKWhYear));
    return ranked;
  }
}
