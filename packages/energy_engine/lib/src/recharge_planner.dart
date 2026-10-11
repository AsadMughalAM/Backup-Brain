import 'dart:math' as math;

import 'backup_calculator.dart';
import 'defaults.dart';

/// "Will my battery be ready before the next outage?" for one outage.
final class Readiness {
  const Readiness({
    required this.hoursUntil,
    required this.socAtStart,
    required this.backup,
    required this.outageHours,
    required this.hoursToFull,
  });

  /// Grid time left to charge before the outage starts.
  final double hoursUntil;

  /// Expected charge when the outage starts, 0–1.
  final double socAtStart;

  /// Backup from [socAtStart] at the current load.
  final BackupEstimate backup;

  /// Expected outage length, when known.
  final double? outageHours;

  /// Grid charging time from now until the battery is full.
  final double hoursToFull;

  /// Null when the outage length is unknown.
  bool? get coversOutage {
    final outage = outageHours;
    return outage == null ? null : backup.hours >= outage;
  }

  bool get fullByThen => hoursToFull <= hoursUntil;
}

/// F8 recharge side: grid charging and discharging over time
/// (ARCHITECTURE.md §5 F8). Solar adds to grid charging; it is not counted
/// here, so the readiness is the honest no-sun case.
final class RechargePlanner {
  const RechargePlanner({this.calculator = const BackupCalculator()});

  final BackupCalculator calculator;

  /// The charger's power, or C/10 of the bank when the user didn't say.
  double chargerW(BackupInput input) =>
      input.inverter.chargerW ??
      input.battery.nominalWh * EngineDefaults.chargeRateC;

  /// `hours_to_full = (target_Wh − current_Wh) / (charger_W × charge_eff)`,
  /// with the part above the taper point at the slower taper rate.
  double hoursToFull(BackupInput input, {double targetSoc = 1}) {
    final rate = _fullRate(input);
    final taper = EngineDefaults.chargeTaperSoc(input.battery.chemistry);
    final fast = math.max(0.0, math.min(targetSoc, taper) - input.socNow);
    final slow = math.max(0.0, targetSoc - math.max(input.socNow, taper));
    return fast / rate + slow / (rate * EngineDefaults.chargeTaperRate);
  }

  /// Charge after [hours] on the grid charger: the full rate up to the
  /// taper point, the taper rate above it, capped at full.
  double socAfterCharging(BackupInput input, double hours) {
    _checkHours(hours);
    final rate = _fullRate(input);
    final taper = EngineDefaults.chargeTaperSoc(input.battery.chemistry);
    var soc = input.socNow;
    var left = hours;
    if (soc < taper) {
      final toTaper = (taper - soc) / rate;
      if (left <= toTaper) return soc + left * rate;
      soc = taper;
      left -= toTaper;
    }
    return math.min(1.0, soc + left * rate * EngineDefaults.chargeTaperRate);
  }

  /// Share of the battery the charger adds per hour below the taper point.
  double _fullRate(BackupInput input) =>
      chargerW(input) * _chargeEfficiency(input) / _capacityWh(input);

  /// Charge after running [loadW] for [hours] on battery: the inverse of F1,
  /// with the same efficiency and lead-acid derate. Never below the cutoff
  /// (the inverter stops there), unless it already started lower.
  double socAfterDischarge(
    BackupInput input, {
    required double loadW,
    required double hours,
  }) {
    _checkHours(hours);
    final estimate = calculator.estimate(input, loadW: loadW);
    final floor = math.min(input.socNow, estimate.minSoc);
    if (estimate.isUnlimited) return input.socNow;
    // Past the backup time the inverter has already cut off.
    if (hours >= estimate.hours) return floor;
    final usedShare = hours / estimate.hours;
    final soc = input.socNow - usedShare * (input.socNow - estimate.minSoc);
    return math.max(floor, soc);
  }

  /// Battery state when an outage starts in [hoursUntil] hours, if the grid
  /// stays on until then and the house keeps drawing [loadW] afterwards.
  Readiness readiness(
    BackupInput input, {
    required double loadW,
    required double hoursUntil,
    double? outageHours,
  }) {
    final socAtStart = socAfterCharging(input, hoursUntil);
    return Readiness(
      hoursUntil: hoursUntil,
      socAtStart: socAtStart,
      backup: calculator.estimate(
        BackupInput(
          battery: input.battery,
          inverter: input.inverter,
          socNow: socAtStart,
          healthFactor: input.healthFactor,
        ),
        loadW: loadW,
      ),
      outageHours: outageHours,
      hoursToFull: hoursToFull(input),
    );
  }

  static double _capacityWh(BackupInput input) =>
      input.battery.nominalWh * input.healthFactor;

  static double _chargeEfficiency(BackupInput input) =>
      EngineDefaults.chargeEfficiency(input.battery.chemistry);

  static void _checkHours(double hours) {
    if (hours < 0 || !hours.isFinite) {
      throw ArgumentError.value(hours, 'hours');
    }
  }
}
