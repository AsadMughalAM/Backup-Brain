import 'package:cloud_firestore/cloud_firestore.dart';
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

  static const _shading = {
    PanelShading.none: 'none',
    PanelShading.partial: 'partial',
    PanelShading.heavy: 'heavy',
  };

  static const _inverterType = {
    InverterType.ups: 'ups',
    InverterType.hybrid: 'hybrid',
    InverterType.ongrid: 'ongrid',
  };

  static HouseholdSystem fromMap(Map<String, dynamic> map) {
    final battery = map['battery'] as Map<String, dynamic>;
    final inverter = map['inverter'] as Map<String, dynamic>;
    final solar = map['solar'] as Map<String, dynamic>?;
    final location = map['location'] as Map<String, dynamic>?;
    return HouseholdSystem(
      // `hasSolar` is stored for queries and rules; the panel spec is the
      // source of truth in the app.
      solar: map['hasSolar'] == true && solar != null
          ? SolarSpec(
              kWp: (solar['kWp'] as num).toDouble(),
              shading: _decode(_shading, solar['shading'] ?? 'none'),
              lastCleanedAt: _time(solar['lastCleanedAt']),
            )
          : null,
      panels: solar?['panelCount'] == null || solar?['panelW'] == null
          ? null
          : PanelArray(
              count: (solar!['panelCount'] as num).toInt(),
              watts: (solar['panelW'] as num).toDouble(),
            ),
      location: location == null
          ? null
          : HomeLocation(
              city: location['city'] as String,
              site: SiteLocation(
                lat: (location['lat'] as num).toDouble(),
                lon: (location['lon'] as num).toDouble(),
              ),
            ),
      soc: (map['soc'] as num).toDouble(),
      socAt: _time(map['socAt']),
      socCheckedAt: _time(map['socCheckedAt']),
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
        chargerW: (inverter['chargerW'] as num?)?.toDouble(),
      ),
    );
  }

  static Map<String, dynamic> toMap(HouseholdSystem s) => {
    'hasSolar': s.hasSolar,
    if (s.solar case final solar?)
      'solar': {
        'kWp': solar.kWp,
        'shading': _shading[solar.shading],
        'lastCleanedAt': ?solar.lastCleanedAt,
        if (s.panels case final panels?) ...{
          'panelCount': panels.count,
          'panelW': panels.watts,
        },
      },
    if (s.location case final location?)
      'location': {
        'city': location.city,
        'lat': location.site.lat,
        'lon': location.site.lon,
      },
    'soc': s.soc,
    'socAt': ?s.socAt,
    'socCheckedAt': ?s.socCheckedAt,
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
      if (s.inverter.chargerW != null) 'chargerW': s.inverter.chargerW,
    },
  };

  /// Firestore gives timestamps; maps built in the app hold DateTimes.
  static DateTime? _time(Object? value) => switch (value) {
    Timestamp t => t.toDate().toUtc(),
    DateTime d => d.toUtc(),
    _ => null,
  };

  static T _decode<T>(Map<T, String> table, Object? value) => table.entries
      .firstWhere(
        (e) => e.value == value,
        orElse: () => throw FormatException('Unknown value: $value'),
      )
      .key;
}
