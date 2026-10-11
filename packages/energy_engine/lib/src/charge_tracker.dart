import 'dart:math' as math;

import 'backup_calculator.dart';
import 'defaults.dart';
import 'recharge_planner.dart';

/// F1 over time: the battery's charge some hours after it was last known,
/// with no link to the inverter (ARCHITECTURE.md §5 F1 "Live estimate").
/// The caller saves a new known point at every change (power cut, power
/// back, load change, the user's own reading), so between two points the
/// grid state and the load are constant.
final class ChargeTracker {
  const ChargeTracker({this.planner = const RechargePlanner()});

  final RechargePlanner planner;

  /// Charge [hours] after [known].socNow was known. With the grid on the
  /// charger fills the battery (the house load runs from the grid); with
  /// it off the house draws [loadW] from the battery.
  double socAfter(
    BackupInput known, {
    required bool gridOn,
    required double loadW,
    required double hours,
  }) {
    // Validates the battery, the charge and the load for both cases.
    planner.calculator.estimate(known, loadW: loadW);
    if (!gridOn) {
      return planner.socAfterDischarge(known, loadW: loadW, hours: hours);
    }
    final charged = planner.socAfterCharging(known, hours);
    // Grid time alone never proves "full"; a higher known charge stays.
    return math.max(
      known.socNow,
      math.min(charged, EngineDefaults.estimatedChargeCap),
    );
  }

  /// Whether the user's last reading of the UPS display is old enough to
  /// ask again. Null = never read.
  bool needsCheck({required double? hoursSinceCheck}) =>
      hoursSinceCheck == null ||
      hoursSinceCheck >= EngineDefaults.chargeCheckAfterHours;
}
