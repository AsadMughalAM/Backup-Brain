import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backup/domain/system_repository.dart';
import 'entities/appliance.dart';

abstract interface class ApplianceRepository {
  /// The signed-in user's appliances in list order; empty when signed out.
  Stream<List<Appliance>> watchAll();

  Future<void> setOn(String id, {required bool isOn});

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

/// F1 + F2 for the current state: backup time, overload and the ranked
/// switch-off list. Null until both the system and appliances have loaded.
/// Every number shown on the dashboard and planner comes from here.
final loadPlanProvider = Provider<LoadPlan?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final appliances = ref.watch(appliancesProvider).value;
  if (system == null || appliances == null) return null;
  return const LoadPlanner().plan(
    system.backupInput,
    appliances: [for (final a in appliances) a.load],
  );
});
