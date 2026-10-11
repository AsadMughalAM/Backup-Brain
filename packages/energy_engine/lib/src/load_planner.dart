import 'backup_calculator.dart';
import 'models/appliance_load.dart';

/// Switching off one appliance on its own.
final class SwitchOffSuggestion {
  const SwitchOffSuggestion({
    required this.appliance,
    required this.estimate,
    required this.hoursGained,
  });

  final ApplianceLoad appliance;

  /// Backup if only this appliance is switched off.
  final BackupEstimate estimate;
  final double hoursGained;

  double get savedW => appliance.effectiveW;
}

/// Switching off several appliances together.
final class SwitchOffSet {
  const SwitchOffSet({
    required this.appliances,
    required this.estimate,
    required this.hoursGained,
  });

  final List<ApplianceLoad> appliances;
  final BackupEstimate estimate;
  final double hoursGained;
}

final class LoadPlan {
  const LoadPlan({
    required this.current,
    required this.suggestions,
    required this.topCombined,
    this.targetHours,
    this.toReachTarget,
  });

  final BackupEstimate current;

  /// Ranked: `avoidOnBackup` first, then highest effective watts.
  final List<SwitchOffSuggestion> suggestions;

  /// The top suggestions applied together ("if you do the top 3").
  final SwitchOffSet topCombined;

  final double? targetHours;

  /// Smallest prefix of [suggestions] that reaches [targetHours], or all of
  /// them when the target can't be reached.
  final SwitchOffSet? toReachTarget;

  bool get targetReached {
    final target = targetHours;
    final set = toReachTarget;
    return target != null && set != null && set.estimate.hours >= target;
  }
}

/// F2 — "What should I turn off first?" (ARCHITECTURE.md §5 F2).
final class LoadPlanner {
  const LoadPlanner({this.calculator = const BackupCalculator()});

  final BackupCalculator calculator;

  static double loadW(Iterable<ApplianceLoad> appliances) =>
      appliances.where((a) => a.isOn).fold(0.0, (sum, a) => sum + a.effectiveW);

  LoadPlan plan(
    BackupInput input, {
    required List<ApplianceLoad> appliances,
    double? targetHours,
    int combineTop = 3,
  }) {
    for (final a in appliances) {
      _validate(a);
    }
    if (targetHours != null && !(targetHours > 0)) {
      throw ArgumentError.value(targetHours, 'targetHours');
    }
    if (combineTop < 1) throw ArgumentError.value(combineTop, 'combineTop');

    final on = appliances.where((a) => a.isOn).toList();
    final current = calculator.estimate(input, loadW: loadW(on));

    BackupEstimate without(Set<ApplianceLoad> off) => calculator.estimate(
      input,
      loadW: loadW(on.where((a) => !off.contains(a))),
    );

    final candidates = _rank(
      on.where((a) => a.priority != AppliancePriority.essential).toList(),
    );

    final suggestions = candidates
        .map((a) {
          final estimate = without({a});
          return SwitchOffSuggestion(
            appliance: a,
            estimate: estimate,
            hoursGained: _gain(estimate, current),
          );
        })
        .toList(growable: false);

    SwitchOffSet setOf(List<ApplianceLoad> off) {
      final estimate = without(off.toSet());
      return SwitchOffSet(
        appliances: List.unmodifiable(off),
        estimate: estimate,
        hoursGained: _gain(estimate, current),
      );
    }

    SwitchOffSet? toReachTarget;
    if (targetHours != null) {
      // Greedy over the ranked list is good enough for the MVP (spec step 6).
      var count = 0;
      while (count < candidates.length &&
          without(candidates.take(count).toSet()).hours < targetHours) {
        count++;
      }
      toReachTarget = setOf(candidates.take(count).toList());
    }

    return LoadPlan(
      current: current,
      suggestions: List.unmodifiable(suggestions),
      topCombined: setOf(candidates.take(combineTop).toList()),
      targetHours: targetHours,
      toReachTarget: toReachTarget,
    );
  }

  // Equal hours (including both unlimited) gain nothing; plain subtraction
  // would turn ∞ − ∞ into NaN.
  static double _gain(BackupEstimate after, BackupEstimate before) =>
      after.hours == before.hours ? 0 : after.hours - before.hours;

  static List<ApplianceLoad> _rank(List<ApplianceLoad> candidates) {
    // Index tiebreak keeps the user's list order for equal watts, because
    // List.sort is not stable.
    final indexed = candidates.indexed.toList()
      ..sort((x, y) {
        final avoidX = x.$2.priority == AppliancePriority.avoidOnBackup;
        final avoidY = y.$2.priority == AppliancePriority.avoidOnBackup;
        if (avoidX != avoidY) return avoidX ? -1 : 1;
        final byWatts = y.$2.effectiveW.compareTo(x.$2.effectiveW);
        return byWatts != 0 ? byWatts : x.$1.compareTo(y.$1);
      });
    return [for (final (_, a) in indexed) a];
  }

  static void _validate(ApplianceLoad a) {
    if (!(a.watts >= 0 && a.watts.isFinite)) {
      throw ArgumentError.value(a.watts, '${a.id}.watts');
    }
    if (a.quantity < 1) {
      throw ArgumentError.value(a.quantity, '${a.id}.quantity');
    }
    if (!(a.dutyCycle > 0 && a.dutyCycle <= 1)) {
      throw ArgumentError.value(a.dutyCycle, '${a.id}.dutyCycle');
    }
  }
}
