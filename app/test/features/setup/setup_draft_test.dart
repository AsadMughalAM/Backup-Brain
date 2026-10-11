import 'package:backup_brain/features/setup/domain/entities/setup_draft.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  final presets = setupPresets();
  final answered = SetupDraft.initial(presets).copyWith(
    cityId: 'lahore',
    hasSolar: false,
    chemistry: BatteryChemistry.tubular,
  );

  test('the bundled presets parse, with every default among its choices', () {
    expect(presets.cities.first.name, 'Karachi');
    expect(presets.appliances.map((a) => a.id), contains('fridge'));
    expect(presets.upsW.options, contains(presets.upsW.fallback));
  });

  test('only city, solar and battery type must be answered', () {
    final fresh = SetupDraft.initial(presets);
    expect(fresh.homeDone, isFalse);
    expect(fresh.batteryDone, isFalse);
    expect(answered.homeDone, isTrue);
    expect(answered.batteryDone, isTrue);
  });

  test('no solar → a UPS, no panels; solar → hybrid with kWp', () {
    final ups = answered.toSystem(presets);
    expect(ups.inverter.type, InverterType.ups);
    expect(ups.solar, isNull);
    expect(ups.location!.site.lat, closeTo(31.52, 0.01));

    final hybrid = answered.copyWith(hasSolar: true).toSystem(presets);
    expect(hybrid.inverter.type, InverterType.hybrid);
    expect(hybrid.solar!.kWp, closeTo(3.3, 1e-9));
  });

  test('switching battery family drops sizes that only fit the old one', () {
    final picked = answered.copyWith(ampHours: 220);
    final lithium = picked.copyWith(
      chemistry: BatteryChemistry.lifepo4,
      resetBatterySizes: true,
    );
    expect(lithium.ampHoursFor(presets), presets.lithium.ampHours.fallback);
    expect(lithium.voltageFor(presets), presets.lithium.voltages.fallback);
  });

  test('heavy appliances are saved switched off; zero counts are left out', () {
    final draft = answered.copyWith(
      quantities: {...answered.quantities, 'iron': 1, 'tv': 0},
    );
    final saved = draft.toAppliances(presets, 'ur');
    final iron = saved.firstWhere((a) => a.id == 'iron');
    expect(iron.isOn, isFalse);
    expect(iron.name, 'Istri');
    expect(saved.any((a) => a.id == 'tv'), isFalse);
    expect(saved.firstWhere((a) => a.id == 'fan').isOn, isTrue);
  });
}
