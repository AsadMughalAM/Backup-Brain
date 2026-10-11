import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One "Light gayi → Light aa gayi" event (ARCHITECTURE.md §8 OutageEvent).
class OutageEvent {
  const OutageEvent({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.startSoc,
    this.endSoc,
    this.endSocMeasured = false,
    this.avgLoadW,
  });

  final String id;
  final DateTime startedAt;

  /// Null while the power is still out.
  final DateTime? endedAt;

  /// Battery charge (0–1) when the power went and when it came back.
  final double? startSoc;
  final double? endSoc;

  /// True when [endSoc] was read off the inverter by the user, not
  /// estimated. Only measured readings tell battery health (F6).
  final bool endSocMeasured;

  /// House load when the power went; the battery estimate assumes it held.
  final double? avgLoadW;

  bool get isOngoing => endedAt == null;

  /// For the engine, in the household's local wall-clock time.
  OutageRecord get record =>
      OutageRecord(start: startedAt.toLocal(), end: endedAt?.toLocal());
}

/// One weekly slot of the user's area schedule.
class ScheduleEntry {
  const ScheduleEntry(this.id, this.slot);

  final String id;
  final ScheduleSlot slot;
}

abstract interface class OutageRepository {
  /// Newest first, the last few weeks — enough for the pattern and the log.
  Stream<List<OutageEvent>> watchRecent();

  /// Writes complete offline at once (TECH_STACK.md §7.2); don't await them
  /// in the UI.
  Future<void> start({required double soc, required double loadW});

  Future<void> end(String id, {required double soc});

  /// The battery % the user read off the inverter when the power came back.
  Future<void> recordEndSoc(String id, double soc);

  Stream<List<ScheduleEntry>> watchSchedule();

  Future<void> addSlot(ScheduleSlot slot);

  Future<void> removeSlot(String id);
}

/// Bound to the Firestore implementation in `app/app_providers.dart`.
final outageRepositoryProvider = Provider<OutageRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

final recentOutagesProvider = StreamProvider<List<OutageEvent>>(
  (ref) => ref.watch(outageRepositoryProvider).watchRecent(),
);

final scheduleProvider = StreamProvider<List<ScheduleEntry>>(
  (ref) => ref.watch(outageRepositoryProvider).watchSchedule(),
);
