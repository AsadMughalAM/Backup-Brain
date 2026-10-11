import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clock.dart';
import '../../../core/utils/fire_and_forget.dart';
import '../../backup/domain/battery_estimate.dart';
import '../../backup/domain/charge_recorder.dart';
import '../../backup/domain/system_repository.dart';
import '../../loads/domain/load_plan.dart';
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

  /// Estimated charge now: the live estimate, drained at the load since
  /// the power went or the load last changed (engine, F1 in reverse).
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

/// Null until the system, appliances and charge have loaded.
final outageOutlookProvider = Provider<OutageOutlook?>((ref) {
  final system = ref.watch(householdSystemProvider).value;
  final plan = ref.watch(loadPlanProvider);
  final charge = ref.watch(batteryEstimateProvider);
  final outages = ref.watch(recentOutagesProvider).value ?? const [];
  final schedule = ref.watch(scheduleProvider).value ?? const [];
  final now = ref.watch(nowProvider).value ?? DateTime.now().toUtc();
  if (system == null || plan == null || charge == null) return null;

  final live = system.copyWith(soc: charge.soc);
  final loadW = plan.current.loadW;
  final ongoingEvent = outages.where((o) => o.isOngoing).firstOrNull;
  final ongoing = ongoingEvent == null
      ? null
      : OngoingOutage(
          event: ongoingEvent,
          hours: _hoursSince(ongoingEvent.startedAt, now),
          socNow: charge.soc,
          backup: plan.current,
        );

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
        : const RechargePlanner().readiness(
            live.backupInput,
            loadW: loadW,
            hoursUntil: next.start.difference(local).inMinutes / 60,
            outageHours: next.hours,
          ),
  );
});

double _hoursSince(DateTime start, DateTime now) {
  final hours = now.difference(start).inMinutes / 60;
  return hours < 0 ? 0 : hours;
}

/// "Light gayi" / "Light aa gayi": logs the event, and saves the battery's
/// estimated charge at that moment as the new known point, so the
/// countdown drains from when the power went and the recharge starts from
/// where the battery really is.
class OutageLogger {
  OutageLogger(this._ref);

  final Ref _ref;

  DateTime get _now => _ref.read(nowProvider).value ?? DateTime.now().toUtc();

  void toggle() {
    final outlook = _ref.read(outageOutlookProvider);
    if (outlook == null) return;
    outlook.ongoing == null ? powerWent() : powerBack();
  }

  /// The power went at [at] (default now; a late log or a reminder gives
  /// an earlier time).
  void powerWent({DateTime? at}) {
    final outlook = _ref.read(outageOutlookProvider);
    if (outlook == null || outlook.ongoing != null) return;
    final start = _notAfterNow(at);
    final soc = _ref.read(chargeRecorderProvider).rebase(at: start);
    fireAndForget(
      _ref
          .read(outageRepositoryProvider)
          .start(at: start, soc: soc, loadW: outlook.loadW),
      'outage start',
    );
  }

  /// The power came back at [at] (default now). A time before the cut
  /// started means the reminder was about an earlier slot: now is used.
  void powerBack({DateTime? at}) {
    final ongoing = _ref.read(outageOutlookProvider)?.ongoing;
    if (ongoing == null) return;
    var end = _notAfterNow(at);
    if (end.isBefore(ongoing.event.startedAt)) end = _now;
    final soc = _ref.read(chargeRecorderProvider).rebase(at: end);
    fireAndForget(
      _ref
          .read(outageRepositoryProvider)
          .end(ongoing.event.id, at: end, soc: soc),
      'outage end',
    );
  }

  /// The user says the power went at [start], not when they tapped.
  void moveStart(DateTime start) {
    final ongoing = _ref.read(outageOutlookProvider)?.ongoing;
    if (ongoing == null) return;
    final at = _notAfterNow(start);
    _ref
        .read(chargeRecorderProvider)
        .retime(from: ongoing.event.startedAt, to: at);
    fireAndForget(
      _ref.read(outageRepositoryProvider).moveStart(ongoing.event.id, at),
      'outage start time',
    );
  }

  /// Logged by mistake: the power didn't go.
  void undo() {
    final ongoing = _ref.read(outageOutlookProvider)?.ongoing;
    if (ongoing == null) return;
    fireAndForget(
      _ref.read(outageRepositoryProvider).remove(ongoing.event.id),
      'outage undo',
    );
  }

  DateTime _notAfterNow(DateTime? at) {
    final now = _now;
    return at == null || at.isAfter(now) ? now : at.toUtc();
  }
}

final outageLoggerProvider = Provider<OutageLogger>(OutageLogger.new);
