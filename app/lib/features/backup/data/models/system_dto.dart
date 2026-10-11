import 'package:energy_engine/energy_engine.dart';

import '../../domain/entities/household_system.dart';

/// Firestore/JSON shape of `systems/{id}` (TECH_STACK.md §4). Enum values
/// use the snake_case strings from ARCHITECTURE.md §8.
abstract final class SystemDto {
  static const _chemistry = {
    BatteryChemistry.leadAcid: 'lead_acid',
    BatteryChemistry.tubular: 'tubular',
    BatteryChemistry.lifepo4: 'lifepo4',
  };

  static const _inverterType = {
    InverterType.ups: 'ups',
    InverterType.hybrid: 'hybrid',
    InverterType.ongrid: 'ongrid',
  };

  static HouseholdSystem fromMap(Map<String, dynamic> map) {
    final battery = map['battery'] as Map<String, dynamic>;
    final inverter = map['inverter'] as Map<String, dynamic>;
    return HouseholdSystem(
      hasSolar: map['hasSolar'] as bool? ?? false,
      soc: (map['soc'] as num).toDouble(),
      battery: BatterySpec(
        chemistry: _decode(_chemistry, battery['chemistry']),
        voltage: (battery['voltage'] as num).toDouble(),
        ampHours: (battery['ah'] as num).toDouble(),
        count: (battery['count'] as num).toInt(),
        minSoc: (battery['minSoC'] as num?)?.toDouble(),
      ),
      inverter: InverterSpec(
        type: _decode(_inverterType, inverter['type']),
        ratedW: (inverter['ratedW'] as num).toDouble(),
        efficiency: (inverter['efficiency'] as num?)?.toDouble(),
      ),
    );
  }

  static Map<String, dynamic> toMap(HouseholdSystem s) => {
    'hasSolar': s.hasSolar,
    'soc': s.soc,
    'battery': {
      'chemistry': _chemistry[s.battery.chemistry],
      'voltage': s.battery.voltage,
      'ah': s.battery.ampHours,
      'count': s.battery.count,
      if (s.battery.minSoc != null) 'minSoC': s.battery.minSoc,
    },
    'inverter': {
      'type': _inverterType[s.inverter.type],
      'ratedW': s.inverter.ratedW,
      if (s.inverter.efficiency != null) 'efficiency': s.inverter.efficiency,
    },
  };

  static T _decode<T>(Map<T, String> table, Object? value) => table.entries
      .firstWhere(
        (e) => e.value == value,
        orElse: () => throw FormatException('Unknown value: $value'),
      )
      .key;
}
