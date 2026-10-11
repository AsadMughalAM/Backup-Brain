import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../domain/pricing_repository.dart';

class ConfigPricingRepository implements PricingRepository {
  ConfigPricingRepository(this._db, {this.bundle});

  final FirebaseFirestore _db;
  final AssetBundle? bundle;

  static const _asset = 'assets/data/pricing_pk.json';

  /// The bundled copy is good enough; don't hold the screen for the network.
  static const _timeout = Duration(seconds: 4);

  @override
  Future<PriceSheet> load() async {
    try {
      final doc = await _db
          .doc(FirestorePaths.pricingConfig)
          .get()
          .timeout(_timeout);
      final data = doc.data();
      if (data != null) return PricingDto.fromMap(data);
    } catch (e) {
      // Offline, signed out or not seeded yet: the bundled copy follows.
      debugPrint('Pricing config unavailable: $e');
    }
    final raw = await (bundle ?? rootBundle).loadString(_asset);
    return PricingDto.fromMap(json.decode(raw) as Map<String, dynamic>);
  }
}

/// Shape of `pricing_pk.json` / `config/pricing_pk`.
abstract final class PricingDto {
  static PriceSheet fromMap(Map<String, dynamic> m) {
    final panel = m['panel'] as Map<String, dynamic>;
    final battery = m['batteryPerKWh'] as Map<String, dynamic>;
    return PriceSheet(
      lastUpdated: m['lastUpdated'] as String,
      verified: m['verified'] == true,
      pricing: SolarPricing(
        panelW: (panel['watts'] as num).toDouble(),
        panelPricePerW: _range(panel['pricePerW']),
        ongridInverter: _bySize(m['ongridInverter']),
        hybridInverter: _bySize(m['hybridInverter']),
        batteryPerKWh: _range(battery['lifepo4']),
        installationPerKw: _range(m['installationPerKw']),
        tariffPerUnit: (m['tariffPerUnit'] as num).toDouble(),
      ),
    );
  }

  static PriceRange _range(Object? v) {
    final m = v as Map<String, dynamic>;
    return PriceRange(
      (m['min'] as num).toDouble(),
      (m['max'] as num).toDouble(),
    );
  }

  static Map<double, PriceRange> _bySize(Object? v) => {
    for (final e in (v as Map<String, dynamic>).entries)
      double.parse(e.key): _range(e.value),
  };
}
