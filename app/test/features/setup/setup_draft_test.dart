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

  group('editing a saved home', () {
    final demo = SetupDraft.fromHousehold(
      presets,
      demoSystem(),
      demoAppliances(),
    );

    test('reads back city, panels and battery as answers', () {
      expect(demo.cityId, 'lahore');
      expect(demo.hasSolar, isTrue);
      expect(demo.panelCount, 4);
      expect(demo.panelWatts, 540);
      expect(demo.chemistry, BatteryChemistry.lifepo4);
      expect(demo.voltage, 24);
      expect(demo.ampHours, 150);
      expect(demo.inverterW, 2000);
      expect(demo.homeDone && demo.batteryDone, isTrue);
    });

    test('appliances of the same type add up; heavy ones are counted', () {
      expect(demo.quantities['fan'], 2); // bedroom + lounge
      expect(demo.quantities['light'], 5);
      expect(demo.quantities['motor'], 1);
      expect(demo.quantities['ac'], 0);
    });

    test('saving it unchanged gives the same household', () {
      final again = demo.toSystem(presets);
      final original = demoSystem();
      expect(again.battery.nominalWh, original.battery.nominalWh);
      expect(again.solar!.kWp, closeTo(original.solar!.kWp, 1e-9));
      expect(again.location!.city, 'Lahore');
    });

    test('a nearby place maps to the closest listed city', () {
      // Wah Cantt is between Islamabad and Peshawar, nearest Islamabad's area.
      final city = presets.nearestCity(
        const SiteLocation(lat: 33.77, lon: 72.75),
      );
      expect(city.id, anyOf('islamabad', 'rawalpindi'));
    });
  });
}
