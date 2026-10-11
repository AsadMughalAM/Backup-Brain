import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../loads/domain/appliance_repository.dart';
import '../../outages/domain/outage_repository.dart';
import 'entities/household_system.dart';
import 'system_repository.dart';

/// The battery's charge right now (ARCHITECTURE.md §5 F1 "Live estimate"):
/// the last known charge worked forward by the engine, draining during a
/// logged power cut and charging while the power is on.
class BatteryEstimate {
  const BatteryEstimate({
    required this.soc,
    required this.gridOn,
    required this.isEstimate,
    required this.needsCheck,
    this.checkedAt,
  });

  final double soc;

  /// No power cut is logged as going on.
  final bool gridOn;

  /// The charge is the app's estimate rather than a reading the user gave:
  /// shown rounded down, with its age. A charge saved without a time
  /// (older households, the demo) is shown as it was given.
  final bool isEstimate;

  /// The user's last reading is old (or missing): worth one question at the
  /// start of a power cut.
  final bool needsCheck;

  /// When the user last read the UPS display themselves.
  final DateTime? checkedAt;
}

/// The last known charge to work forward from. A cut logged before known
/// charges carried a time has its own start charge: that is the newer
/// known point.
HouseholdSystem knownCharge(HouseholdSystem system, OutageEvent? ongoing) {
  final startSoc = ongoing?.startSoc;
  if (ongoing == null || startSoc == null) return system;
  final knownAt = system.socAt;
  if (knownAt != null && !knownAt.isBefore(ongoing.startedAt)) return system;
  return system.copyWith(soc: startSoc, socAt: ongoing.startedAt.toUtc());
}

/// The engine's charge at [at] for [system], with the grid [gridOn] and the
/// house drawing [loadW] since the last known charge. A known charge newer
/// than [at] is kept as it is.
double chargeAt(
  HouseholdSystem system, {
  required bool gridOn,
  required double loadW,
  required DateTime at,
}) {
  final knownAt = system.socAt;
  if (knownAt == null || !at.isAfter(knownAt)) return system.soc;
  return const ChargeTracker().socAfter(
    system.backupInput,
    gridOn: gridOn,
    loadW: loadW,
    hours: at.difference(knownAt).inSeconds / 3600,
  );
}

/// Null until the system, appliances and outage log have loaded.
final batteryEstimateProvider = Provider<BatteryEstimate?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final appliances = ref.watch(appliancesProvider).value;
  final outages = ref.watch(recentOutagesProvider);
  final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
  if (system == null || appliances == null) return null;
  // A failed outage read shouldn't hide the countdown: treat it as no cut.
  if (outages.isLoading && !outages.hasValue) return null;
  final ongoing = (outages.value ?? const [])
      .where((o) => o.isOngoing)
      .firstOrNull;
  final known = knownCharge(system, ongoing);

  final soc = chargeAt(
    known,
    gridOn: ongoing == null,
    loadW: LoadPlanner.loadW([for (final a in appliances) a.load]),
    at: now,
  );
  final checkedAt = known.socCheckedAt;
  final knownAt = known.socAt;
  return BatteryEstimate(
    soc: soc,
    gridOn: ongoing == null,
    isEstimate:
        knownAt != null &&
        (checkedAt == null ||
            !knownAt.isAtSameMomentAs(checkedAt) ||
            (soc - known.soc).abs() > _sameCharge),
    needsCheck: const ChargeTracker().needsCheck(
      hoursSinceCheck: checkedAt == null
          ? null
          : now.difference(checkedAt).inSeconds / 3600,
    ),
    checkedAt: checkedAt,
  );
});

/// Below a tenth of a percent the charge hasn't moved from the reading.
const _sameCharge = 0.001;
