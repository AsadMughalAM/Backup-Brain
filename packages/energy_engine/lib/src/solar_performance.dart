import 'defaults.dart';

/// One day's panel output: what the inverter says, against what F3's model
/// expected for that day's actual weather.
final class DayPerformance {
  const DayPerformance({
    required this.day,
    required this.actualKWh,
    required this.expectedKWh,
    required this.clearShare,
  });

  /// Local calendar day.
  final DateTime day;
  final double actualKWh;
  final double expectedKWh;

  /// Expected ÷ clear-sky energy that day: near 1 on a sunny day.
  final double clearShare;

  /// `performance_index = actual_kWh / expected_kWh`.
  double get index => actualKWh / expectedKWh;

  bool get isClear => clearShare >= EngineDefaults.clearDayShare;
}

enum PerformanceStatus {
  /// ≥ 0.90 of expected.
  healthy,

  /// 0.75–0.90, or one low day: likely dust or partial shading.
  slightlyLow,

  /// < 0.75 on 3+ clear days within a week: wiring, MPPT or a panel.
  significantlyLow,
}

/// F4 — "Is my solar system underperforming?" (ARCHITECTURE.md §5 F4).
final class SolarPerformance {
  const SolarPerformance();

  /// [days] in any order. Null when no day had enough expected sun to judge.
  PerformanceStatus? status(List<DayPerformance> days) {
    final judged = [
      for (final d in days)
        if (d.expectedKWh >= EngineDefaults.minExpectedKWh) d,
    ]..sort((a, b) => a.day.compareTo(b.day));
    if (judged.isEmpty) return null;

    final latest = judged.last;
    final weekStart = latest.day.subtract(
      const Duration(days: EngineDefaults.performanceWindowDays - 1),
    );
    final lowClearDays = judged
        .where(
          (d) =>
              !d.day.isBefore(weekStart) &&
              d.isClear &&
              d.index < EngineDefaults.performanceLow,
        )
        .length;
    if (lowClearDays >= EngineDefaults.lowClearDaysForAlarm) {
      return PerformanceStatus.significantlyLow;
    }
    return latest.index >= EngineDefaults.performanceHealthy
        ? PerformanceStatus.healthy
        : PerformanceStatus.slightlyLow;
  }
}
