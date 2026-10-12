import 'package:energy_engine/energy_engine.dart';

import '../../domain/entities/setup_presets.dart';

/// Reads `cities_psh.json`, `appliances_pk.json` and `equipment_pk.json`.
abstract final class SetupPresetsDto {
  static const _priority = {
    'essential': AppliancePriority.essential,
    'comfort': AppliancePriority.comfort,
    'avoid_on_backup': AppliancePriority.avoidOnBackup,
  };

  static SetupPresets fromJson({
    required Map<String, dynamic> cities,
    required Map<String, dynamic> appliances,
    required Map<String, dynamic> equipment,
  }) {
    final battery = equipment['battery'] as Map<String, dynamic>;
    final inverter = equipment['inverterW'] as Map<String, dynamic>;
    final panels = equipment['panels'] as Map<String, dynamic>;
    final count = equipment['batteryCount'] as Map<String, dynamic>;
    return SetupPresets(
      cities: [
        for (final c in _list(cities['cities']))
          CityPreset(
            id: c['id'] as String,
            name: c['name'] as String,
            site: SiteLocation(lat: _d(c['lat']), lon: _d(c['lon'])),
            psh: (c['psh'] as num?)?.toDouble(),
          ),
      ],
      applianceWatts: _valueRange(appliances['wattsRange']),
      appliances: [
        for (final a in _list(appliances['appliances']))
          AppliancePreset(
            id: a['id'] as String,
            names: (a['name'] as Map<String, dynamic>).cast<String, String>(),
            iconKey: a['icon'] as String,
            watts: _d(a['watts']),
            dutyCycle: _d(a['dutyCycle'] ?? 1),
            priority:
                _priority[a['priority']] ??
                (throw FormatException('Unknown priority: ${a['priority']}')),
            defaultQuantity: (a['defaultQuantity'] as num).toInt(),
            variants: [
              for (final v in _list(a['variants'] ?? const <Object>[]))
                ApplianceVariant(
                  names: (v['name'] as Map<String, dynamic>)
                      .cast<String, String>(),
                  watts: _d(v['watts']),
                ),
            ],
          ),
      ],
      leadAcid: _battery(battery['leadAcid'] as Map<String, dynamic>),
      lithium: _battery(battery['lithium'] as Map<String, dynamic>),
      batteryCount: _range(count, 'min', 'max', 'default'),
      upsW: _sizes(
        inverter['ups'],
        inverter['upsDefault'],
        inverter['upsRange'],
      ),
      hybridW: _sizes(
        inverter['hybrid'],
        inverter['hybridDefault'],
        inverter['hybridRange'],
      ),
      panelWatts: _sizes(
        panels['watts'],
        panels['defaultWatts'],
        panels['wattsRange'],
      ),
      panelCount: _range(panels, 'countMin', 'countMax', 'defaultCount'),
      socChoices: [for (final v in equipment['socChoices'] as List) _d(v)],
      defaultSoc: _d(equipment['defaultSoc']),
    );
  }

  static BatteryPreset _battery(Map<String, dynamic> m) => BatteryPreset(
    voltages: _sizes(
      m['voltages'],
      m['defaultVoltage'],
      // Lead-acid has one voltage and no "Other".
      m['voltagesRange'] ?? [m['defaultVoltage'], m['defaultVoltage']],
    ),
    ampHours: _sizes(m['ampHours'], m['defaultAmpHours'], m['ampHoursRange']),
  );

  static SizeChoices _sizes(Object? options, Object? fallback, Object? range) {
    final values = [for (final v in options as List) _d(v)];
    final pick = _d(fallback);
    if (!values.contains(pick)) {
      throw FormatException('Default $pick is not one of $values');
    }
    final custom = _valueRange(range);
    if (values.any((v) => v < custom.min || v > custom.max)) {
      throw FormatException(
        '$values reach outside ${custom.min}–${custom.max}',
      );
    }
    return SizeChoices(options: values, fallback: pick, custom: custom);
  }

  /// `[min, max]`.
  static ValueRange _valueRange(Object? v) {
    final pair = v as List;
    return ValueRange(min: _d(pair[0]), max: _d(pair[1]));
  }

  static CountRange _range(
    Map<String, dynamic> m,
    String min,
    String max,
    String fallback,
  ) => CountRange(
    min: (m[min] as num).toInt(),
    max: (m[max] as num).toInt(),
    fallback: (m[fallback] as num).toInt(),
  );

  static List<Map<String, dynamic>> _list(Object? v) =>
      (v as List).cast<Map<String, dynamic>>();

  static double _d(Object? v) => (v as num).toDouble();
}
