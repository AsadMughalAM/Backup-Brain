import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/entities/setup_presets.dart';
import '../domain/setup_presets_repository.dart';
import 'models/setup_presets_dto.dart';

class AssetSetupPresetsRepository implements SetupPresetsRepository {
  const AssetSetupPresetsRepository();

  static const _dir = 'assets/data';

  @override
  Future<SetupPresets> load() async {
    final (cities, appliances, equipment) = await (
      _json('$_dir/cities_psh.json'),
      _json('$_dir/appliances_pk.json'),
      _json('$_dir/equipment_pk.json'),
    ).wait;
    return SetupPresetsDto.fromJson(
      cities: cities,
      appliances: appliances,
      equipment: equipment,
    );
  }

  static Future<Map<String, dynamic>> _json(String path) async =>
      json.decode(await rootBundle.loadString(path)) as Map<String, dynamic>;
}
