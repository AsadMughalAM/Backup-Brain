import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backup/domain/battery_estimate.dart';
import '../../backup/domain/system_repository.dart';
import 'appliance_repository.dart';

/// F1 + F2 for the current state: backup time, overload and the ranked
/// switch-off list, from the battery's live charge. Null until the system,
/// appliances and charge have loaded. Every number shown on the dashboard
/// and planner comes from here.
final loadPlanProvider = Provider<LoadPlan?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final appliances = ref.watch(appliancesProvider).value;
  final charge = ref.watch(batteryEstimateProvider);
  if (system == null || appliances == null || charge == null) return null;
  return const LoadPlanner().plan(
    system.copyWith(soc: charge.soc).backupInput,
    appliances: [for (final a in appliances) a.load],
  );
});
