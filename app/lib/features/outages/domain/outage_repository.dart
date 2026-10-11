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
    this.avgLoadW,
  });

  final String id;
  final DateTime startedAt;

  /// Null while the power is still out.
  final DateTime? endedAt;

  /// Battery charge (0–1) when the power went and when it came back.
  final double? startSoc;
  final double? endSoc;

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
  /// in the UI. [at] is when the power went: now, or earlier when the user
  /// logs it late or confirms a reminder.
  Future<void> start({
    required DateTime at,
    required double soc,
    required double loadW,
  });

  Future<void> end(String id, {required DateTime at, required double soc});

  /// The user corrected when the power went.
  Future<void> moveStart(String id, DateTime at);

  /// Logged by mistake ("the power didn't go").
  Future<void> remove(String id);

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
