import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Battery types to compare, with when their prices were checked.
class BatteryCatalog {
  const BatteryCatalog({
    required this.options,
    required this.lastUpdated,
    required this.verified,
  });

  final List<BatteryOption> options;
  final String lastUpdated;

  /// False while the prices are placeholders nobody has checked.
  final bool verified;
}

abstract interface class BatteryCatalogRepository {
  /// Bundled with the app, so it works offline.
  Future<BatteryCatalog> load();
}

/// Bound in `app/app_providers.dart`.
final batteryCatalogRepositoryProvider = Provider<BatteryCatalogRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final batteryCatalogProvider = FutureProvider<BatteryCatalog>(
  (ref) => ref.watch(batteryCatalogRepositoryProvider).load(),
);
