import 'dart:math' as math;

import 'defaults.dart';
import 'models/battery_spec.dart';
import 'models/inverter_spec.dart';

/// One outage on battery with the charge the user read off the inverter
/// when the power came back (an estimate would only echo the model).
final class DischargeSession {
  const DischargeSession({
    required this.startSoc,
    required this.endSoc,
    required this.avgLoadW,
    required this.hours,
  });

  final double startSoc;
  final double endSoc;
  final double avgLoadW;
  final double hours;
}

enum HealthWarning {
  /// Delivers noticeably less than when new (or than at the first readings).
  capacityLoss,

  /// Often drained below the chemistry's safe minimum.
  deepDischarge,
}

final class BatteryHealth {
  const BatteryHealth({
    required this.healthFactor,
    required this.capacityWh,
    required this.nominalWh,
    required this.sessionsUsed,
    required this.capacityLoss,
    required this.warnings,
  });

  /// Remaining capacity vs. nominal, 0–1.
  final double healthFactor;
  final double capacityWh;
  final double nominalWh;
  final int sessionsUsed;

  /// Share lost against the baseline (nominal, or the first readings once
  /// there are enough).
  final double capacityLoss;
  final List<HealthWarning> warnings;
}

/// F6 — "Is my battery becoming unhealthy?" (ARCHITECTURE.md §5 F6).
final class BatteryHealthMonitor {
  const BatteryHealthMonitor();

  /// [sessions] oldest first. Null until there are enough usable readings.
  ///
  /// ```
  /// delivered_Wh          = avg_load_W × duration_h / inverter_eff
  /// estimated_capacity_Wh = delivered_Wh / (start_SoC − end_SoC)
  /// health_factor         = median(capacity, last 10 sessions) / nominal_Wh
  /// ```
  BatteryHealth? assess(
    BatterySpec battery,
    InverterSpec inverter,
    List<DischargeSession> sessions,
  ) {
    final efficiency =
        inverter.efficiency ?? EngineDefaults.inverterEfficiency(inverter.type);
    final nominal = battery.nominalWh;

    // Small drops are mostly reading error: 5% misread on a 10% drop is a
    // 50% error in capacity.
    final usable = [
      for (final s in sessions)
        if (s.startSoc - s.endSoc >= EngineDefaults.healthMinSocDrop &&
            s.hours > 0 &&
            s.avgLoadW > 0)
          s.avgLoadW * s.hours / efficiency / (s.startSoc - s.endSoc),
    ];
    if (usable.length < EngineDefaults.healthMinSessions) return null;

    final recent = usable.sublist(
      math.max(0, usable.length - EngineDefaults.healthWindow),
    );
    final capacity = _median(recent);
    final health = (capacity / nominal).clamp(0.0, 1.0);

    // Against the first readings once there are two windows' worth, else
    // against the label.
    final enoughHistory = usable.length >= 2 * EngineDefaults.healthMinSessions;
    final baseline = enoughHistory
        ? math.min(
            1.0,
            _median(usable.take(EngineDefaults.healthMinSessions)) / nominal,
          )
        : 1.0;
    final loss = baseline <= 0 ? 0.0 : math.max(0.0, 1 - health / baseline);

    final deep = sessions
        .where((s) => s.endSoc < battery.cutoffSoc - _readingSlack)
        .length;

    return BatteryHealth(
      healthFactor: health,
      capacityWh: math.min(capacity, nominal),
      nominalWh: nominal,
      sessionsUsed: recent.length,
      capacityLoss: loss,
      warnings: [
        if (loss > EngineDefaults.capacityLossWarning)
          HealthWarning.capacityLoss,
        if (sessions.isNotEmpty &&
            deep / sessions.length > EngineDefaults.deepDischargeShare)
          HealthWarning.deepDischarge,
      ],
    );
  }

  /// A reading 2% under the cutoff is a rounding, not a deep discharge.
  static const _readingSlack = 0.02;

  static double _median(Iterable<double> values) {
    final sorted = values.toList()..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }
}
