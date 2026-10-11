import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/appliance.dart';

abstract interface class ApplianceRepository {
  /// The signed-in user's appliances in list order; empty when signed out.
  Stream<List<Appliance>> watchAll();

  Future<void> setOn(String id, {required bool isOn});

  /// The user picked what their appliance really draws (watts each).
  Future<void> setWatts(String id, double watts);

  /// Writes the appliances picked during setup. [removing] are deleted in
  /// the same batch, so an edit never shows half old, half new.
  Future<void> addAll(
    List<Appliance> appliances, {
    Set<String> removing = const {},
  });

  /// Writes the bundled demo household's appliances (Demo Mode).
  Future<void> loadDemo();
}

/// Bound to the Firestore implementation in `app/app_providers.dart`.
final applianceRepositoryProvider = Provider<ApplianceRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final appliancesProvider = StreamProvider<List<Appliance>>(
  (ref) => ref.watch(applianceRepositoryProvider).watchAll(),
);
