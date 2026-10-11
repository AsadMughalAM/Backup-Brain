import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../../core/utils/fire_and_forget.dart';
import '../../loads/domain/appliance_repository.dart';
import '../../outages/domain/outage_repository.dart';
import 'battery_estimate.dart';
import 'system_repository.dart';

/// Saves new known charges, so the live estimate restarts from the right
/// point whenever how the battery is used changes. Writes are not awaited
/// (TECH_STACK.md §7.2).
class ChargeRecorder {
  ChargeRecorder(this._ref);

  final Ref _ref;

  DateTime get _now => _ref.read(nowProvider).value ?? DateTime.now().toUtc();

  /// The user read [soc] (0–1) off the UPS display just now.
  void confirm(double soc) => fireAndForget(
    _ref.read(systemRepositoryProvider).setCharge(soc, at: _now, checked: true),
    'battery reading',
  );

  /// Saves the estimated charge at [at] (default now) as the new known
  /// point, before the power goes or comes back or the load changes during
  /// a cut. Returns that charge. A newer known charge (the user read it
  /// later) is kept.
  double rebase({DateTime? at}) {
    final saved = _ref.read(householdSystemProvider).value;
    final appliances = _ref.read(appliancesProvider).value;
    final estimate = _ref.read(batteryEstimateProvider);
    if (saved == null || appliances == null || estimate == null) {
      return saved?.soc ?? 0;
    }
    final ongoing = (_ref.read(recentOutagesProvider).value ?? const [])
        .where((o) => o.isOngoing)
        .firstOrNull;
    final system = knownCharge(saved, ongoing);
    final when = at ?? _now;
    final knownAt = system.socAt;
    if (knownAt != null && !when.isAfter(knownAt)) return system.soc;
    final soc = chargeAt(
      system,
      gridOn: estimate.gridOn,
      loadW: LoadPlanner.loadW([for (final a in appliances) a.load]),
      at: when,
    );
    fireAndForget(
      _ref.read(systemRepositoryProvider).setCharge(soc, at: when),
      'battery estimate',
    );
    return soc;
  }

  /// A logged moment moved from [from] to [to] (the user corrected when
  /// the power went): the known charge saved at that moment moves with it,
  /// unless it was the user's own reading.
  void retime({required DateTime from, required DateTime to}) {
    final system = _ref.read(householdSystemProvider).value;
    final knownAt = system?.socAt;
    if (system == null || knownAt == null) return;
    if (!knownAt.isAtSameMomentAs(from)) return;
    if (system.socCheckedAt?.isAtSameMomentAs(from) ?? false) return;
    fireAndForget(
      _ref.read(systemRepositoryProvider).setCharge(system.soc, at: to),
      'battery estimate time',
    );
  }
}

final chargeRecorderProvider = Provider<ChargeRecorder>(ChargeRecorder.new);
