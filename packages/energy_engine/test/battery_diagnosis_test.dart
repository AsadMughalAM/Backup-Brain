import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

void main() {
  const diagnosis = BatteryDiagnosis();
  const tubular = BatteryChemistry.tubular;

  group('repair or replace', () {
    test('swelling or smell/heat is unsafe whatever else is picked', () {
      expect(
        diagnosis.diagnose({BatterySymptom.swollen}, tubular),
        BatteryVerdict.unsafe,
      );
      expect(
        diagnosis.diagnose({
          BatterySymptom.smellOrHeat,
          BatterySymptom.lowWater,
        }, tubular),
        BatteryVerdict.unsafe,
      );
    });

    test('low water in a tubular battery: top it up first', () {
      expect(
        diagnosis.diagnose({BatterySymptom.lowWater}, tubular),
        BatteryVerdict.tryMaintenance,
      );
    });

    test('won\'t charge: a repair shop can check charger and wiring', () {
      expect(
        diagnosis.diagnose({BatterySymptom.wontCharge}, tubular),
        BatteryVerdict.repairPossible,
      );
    });

    test('short backup: maintenance unless F6 measured a worn battery', () {
      expect(
        diagnosis.diagnose({BatterySymptom.shortBackup}, tubular),
        BatteryVerdict.tryMaintenance,
      );
      expect(
        diagnosis.diagnose(
          {BatterySymptom.shortBackup},
          tubular,
          healthFactor: 0.5,
        ),
        BatteryVerdict.replace,
      );
      expect(
        diagnosis.diagnose(
          {BatterySymptom.shortBackup},
          tubular,
          healthFactor: 0.8,
        ),
        BatteryVerdict.tryMaintenance,
      );
    });

    test('nothing picked: no issue', () {
      expect(diagnosis.diagnose({}, tubular), BatteryVerdict.noIssue);
    });
  });

  group('which battery to buy', () {
    const options = [
      BatteryOption(
        id: 'tubular',
        chemistry: BatteryChemistry.tubular,
        pricePerKWh: PriceRange(18000, 24000),
        cycleLife: 1200,
        warrantyMonths: 24,
      ),
      BatteryOption(
        id: 'lithium',
        chemistry: BatteryChemistry.lifepo4,
        pricePerKWh: PriceRange(45000, 65000),
        cycleLife: 3500,
        warrantyMonths: 60,
      ),
    ];

    test('lithium costs more upfront but less per usable kWh per year', () {
      final ranked = const BatteryRanking().rank(options, 2400);
      expect(ranked.first.option.id, 'lithium');
      // Tubular: 21,000 × 2.4 = 50,400 / (2.4 × 0.5 usable × 1200/365 y).
      final tubular = ranked.last;
      expect(tubular.price.min, closeTo(18000 * 2.4, 1e-6));
      expect(
        tubular.costPerUsableKWhYear,
        closeTo(50400 / (1.2 * 1200 / 365), 1e-6),
      );
      expect(ranked.first.price.min, greaterThan(tubular.price.max));
    });
  });
}
