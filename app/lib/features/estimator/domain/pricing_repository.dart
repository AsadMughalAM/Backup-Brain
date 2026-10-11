import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// F5 prices plus what the screen must say about them (ARCHITECTURE §5 F5:
/// always show when prices were updated).
class PriceSheet {
  const PriceSheet({
    required this.pricing,
    required this.lastUpdated,
    required this.verified,
  });

  final SolarPricing pricing;

  /// When the prices were last checked, as written in the config
  /// ("2026-10-11").
  final String lastUpdated;

  /// False while the prices are placeholders nobody has checked with
  /// installers.
  final bool verified;
}

abstract interface class PricingRepository {
  /// Firestore `config/pricing_pk` when it exists and can be read, else the
  /// copy bundled with the app — so the estimator works offline.
  Future<PriceSheet> load();
}

/// Bound in `app/app_providers.dart`.
final pricingRepositoryProvider = Provider<PricingRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final priceSheetProvider = FutureProvider<PriceSheet>(
  (ref) => ref.watch(pricingRepositoryProvider).load(),
);
