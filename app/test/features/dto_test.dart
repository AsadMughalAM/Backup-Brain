import 'package:backup_brain/features/backup/data/models/system_dto.dart';
import 'package:backup_brain/features/loads/data/models/appliance_dto.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('SystemDto', () {
    test('reads the demo household with the snake_case enums', () {
      final s = demoSystem();
      expect(s.battery.chemistry, BatteryChemistry.lifepo4);
      expect(s.battery.nominalWh, 3600);
      expect(s.inverter.type, InverterType.hybrid);
      expect(s.inverter.ratedW, 2000);
      expect(s.soc, 0.6);
    });

    test('round-trips through the Firestore map', () {
      final s = demoSystem();
      final again = SystemDto.fromMap(SystemDto.toMap(s));
      expect(SystemDto.toMap(again), SystemDto.toMap(s));
      expect(
        SystemDto.toMap(s)['battery'],
        containsPair('chemistry', 'lifepo4'),
      );
    });

    test('unknown enum values fail loudly', () {
      final map = SystemDto.toMap(demoSystem());
      (map['battery'] as Map<String, dynamic>)['chemistry'] = 'nicad';
      expect(() => SystemDto.fromMap(map), throwsFormatException);
    });
  });

  group('ApplianceDto', () {
    test('demo appliances add up to the 420 W in ARCHITECTURE §12', () {
      final total = LoadPlanner.loadW([
        for (final a in demoAppliances()) a.load,
      ]);
      expect(total, closeTo(420, 1e-9));
    });

    test('round-trips and keeps avoid_on_backup', () {
      final iron = demoAppliances().firstWhere((a) => a.id == 'iron');
      final map = ApplianceDto.toMap(iron);
      expect(map['priority'], 'avoid_on_backup');
      final again = ApplianceDto.fromMap('iron', map);
      expect(again.priority, AppliancePriority.avoidOnBackup);
      expect(again.isOn, isFalse);
    });
  });
}
