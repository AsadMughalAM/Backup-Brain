import 'dart:convert';

import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/services.dart';

import '../domain/battery_catalog_repository.dart';

class AssetBatteryCatalogRepository implements BatteryCatalogRepository {
  const AssetBatteryCatalogRepository({this.bundle});

  final AssetBundle? bundle;

  static const _asset = 'assets/data/battery_catalog_pk.json';

  @override
  Future<BatteryCatalog> load() async => BatteryCatalogDto.fromMap(
    json.decode(await (bundle ?? rootBundle).loadString(_asset))
        as Map<String, dynamic>,
  );
}

/// Shape of `battery_catalog_pk.json`; chemistry strings as in
/// ARCHITECTURE.md §8.
abstract final class BatteryCatalogDto {
  static const _chemistry = {
    'lead_acid': BatteryChemistry.leadAcid,
    'tubular': BatteryChemistry.tubular,
    'lifepo4': BatteryChemistry.lifepo4,
  };

  static BatteryCatalog fromMap(Map<String, dynamic> m) => BatteryCatalog(
    lastUpdated: m['lastUpdated'] as String,
    verified: m['verified'] == true,
    options: [
      for (final o in (m['options'] as List).cast<Map<String, dynamic>>())
        BatteryOption(
          id: o['id'] as String,
          chemistry:
              _chemistry[o['chemistry']] ??
              (throw FormatException('Unknown chemistry: ${o['chemistry']}')),
          pricePerKWh: PriceRange(
            ((o['pricePerKWh'] as Map)['min'] as num).toDouble(),
            ((o['pricePerKWh'] as Map)['max'] as num).toDouble(),
          ),
          cycleLife: (o['cycleLife'] as num).toInt(),
          warrantyMonths: (o['warrantyMonths'] as num).toInt(),
        ),
    ],
  );
}
