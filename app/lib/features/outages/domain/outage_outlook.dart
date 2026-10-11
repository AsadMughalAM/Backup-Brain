import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../../core/utils/fire_and_forget.dart';
import '../../backup/domain/system_repository.dart';
import '../../loads/domain/appliance_repository.dart';
import 'outage_repository.dart';

/// The power is out right now.
class OngoingOutage {
  const OngoingOutage({
    required this.event,
    required this.hours,
    required this.socNow,
    required this.backup,
  });

  final OutageEvent event;

  /// How long it has been out.
  final double hours;

  /// Estimated charge now: the charge when it went, drained at the load
  /// since then (engine, F1 in reverse).
  final double socNow;

  /// Backup left from [socNow] at the current load.
  final BackupEstimate backup;
}

/// F8 for the current moment. Every outage number on screen comes from here.
class OutageOutlook {
  const OutageOutlook({
    required this.loadW,
    this.ongoing,
    this.next,
    this.readiness,
  });

  final double loadW;
  final OngoingOutage? ongoing;

  /// Null when neither the schedule nor the logs predict anything yet.
  final OutagePrediction? next;

  /// The battery when [next] starts; null during an outage or without [next].
  final Readiness? readiness;
}

/// Null until the system and appliances have loaded.
final outageOutlookProvider = Provider<OutageOutlook?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final plan = ref.watch(loadPlanProvider);
  final outages = ref.watch(recentOutagesProvider).value ?? const [];
  final schedule = ref.watch(scheduleProvider).value ?? const [];
  final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
  if (system == null || plan == null) return null;

  const planner = RechargePlanner();
  final loadW = plan.current.loadW;
  final ongoingEvent = outages.where((o) => o.isOngoing).firstOrNull;

  OngoingOutage? ongoing;
  if (ongoingEvent != null) {
    final hours = now.difference(ongoingEvent.startedAt).inMinutes / 60;
    final soc = planner.socAfterDischarge(
      system.copyWith(soc: ongoingEvent.startSoc ?? system.soc).backupInput,
      loadW: ongoingEvent.avgLoadW ?? loadW,
      hours: hours < 0 ? 0 : hours,
    );
    ongoing = OngoingOutage(
      event: ongoingEvent,
      hours: hours,
      socNow: soc,
      backup: planner.calculator.estimate(
        system.copyWith(soc: soc).backupInput,
        loadW: loadW,
      ),
    );
  }

  final local = now.toLocal();
  final next = const OutagePattern().next(
    now: local,
    history: [for (final o in outages) o.record],
    schedule: [for (final e in schedule) e.slot],
  );

  return OutageOutlook(
    loadW: loadW,
    ongoing: ongoing,
    next: next,
    readiness: ongoing != null || next == null
        ? null
        : planner.readiness(
            system.backupInput,
            loadW: loadW,
            hoursUntil: next.start.difference(local).inMinutes / 60,
            outageHours: next.hours,
          ),
  );
});

/// "Light gayi" / "Light aa gayi": logs the event. When the power comes back
/// the battery's charge is set to the engine's estimate, so the countdown
/// and the recharge forecast start from where the battery really is; the
/// user can still correct it on the load planner.
class OutageLogger {
  OutageLogger(this._ref);

  final Ref _ref;

  void toggle() {
    final outlook = _ref.read(outageOutlookProvider);
    final system = _ref.read(householdSystemProvider).value;
    if (outlook == null || system == null) return;
    final repo = _ref.read(outageRepositoryProvider);
    final ongoing = outlook.ongoing;
    if (ongoing == null) {
      fireAndForget(
        repo.start(soc: system.soc, loadW: outlook.loadW),
        'outage start',
      );
      return;
    }
    fireAndForget(
      repo.end(ongoing.event.id, soc: ongoing.socNow),
      'outage end',
    );
    fireAndForget(
      _ref.read(systemRepositoryProvider).setSoc(ongoing.socNow),
      'soc after outage',
    );
  }
}

final outageLoggerProvider = Provider<OutageLogger>(OutageLogger.new);
