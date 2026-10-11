import 'package:backup_brain/features/backup/data/models/system_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    test('demo household has 2.16 kWp panels in Lahore', () {
      final s = demoSystem();
      expect(s.hasSolar, isTrue);
      expect(s.solar!.kWp, 2.16);
      expect(s.solar!.shading, PanelShading.none);
      expect(s.location!.city, 'Lahore');
      expect(s.location!.site.lat, 31.5204);
      expect(s.panels!.count, 4);
      expect(s.panels!.watts, 540);
      expect(
        SystemDto.fromMap(SystemDto.toMap(s)).panels!.count,
        4,
        reason: 'panel details survive a save',
      );
    });

    test('the known charge, its times and the panel cleaning survive a '
        'save', () {
      final demo = demoSystem();
      final at = DateTime.utc(2026, 10, 11, 14, 5);
      final s = demo.copyWith(
        soc: 0.45,
        socAt: at,
        socCheckedAt: at.subtract(const Duration(hours: 2)),
        solar: SolarSpec(
          kWp: demo.solar!.kWp,
          shading: PanelShading.partial,
          lastCleanedAt: at,
        ),
      );
      final again = SystemDto.fromMap(SystemDto.toMap(s));
      expect(again.soc, 0.45);
      expect(again.socAt, at);
      expect(again.socCheckedAt, at.subtract(const Duration(hours: 2)));
      expect(again.solar!.shading, PanelShading.partial);
      expect(again.solar!.lastCleanedAt, at);
      // Firestore hands back Timestamps.
      final fromFirestore = SystemDto.fromMap({
        ...SystemDto.toMap(s),
        'socAt': Timestamp.fromDate(at),
      });
      expect(fromFirestore.socAt, at);
    });

    test('older households have no charge time: nothing invented', () {
      final s = demoSystem();
      expect(s.socAt, isNull);
      expect(SystemDto.toMap(s).containsKey('socAt'), isFalse);
    });

    test('hasSolar false drops the panel spec', () {
      final map = SystemDto.toMap(demoSystem())..['hasSolar'] = false;
      final s = SystemDto.fromMap(map);
      expect(s.solar, isNull);
      expect(SystemDto.toMap(s).containsKey('solar'), isFalse);
    });

    test('unknown enum values fail loudly', () {
      final map = SystemDto.toMap(demoSystem());
      (map['battery'] as Map<String, dynamic>)['chemistry'] = 'nicad';
      expect(() => SystemDto.fromMap(map), throwsFormatException);
    });
  });

  test(
    'every appliance preset offers its kinds, including its usual watts',
    () {
      for (final preset in setupPresets().appliances) {
        expect(preset.variants, isNotEmpty, reason: preset.id);
        expect(
          preset.variants.map((v) => v.watts),
          contains(preset.watts),
          reason: preset.id,
        );
        expect(preset.variants.first.name('ur'), isNotEmpty);
      }
    },
  );

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
