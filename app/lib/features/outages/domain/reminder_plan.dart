import 'package:energy_engine/energy_engine.dart';

enum ReminderKind {
  /// "Power gone?" a little after an expected cut starts.
  cut,

  /// "Power back?" a little after a cut in progress should end.
  back,
}

/// One local notification asking the user to confirm a cut or its end.
class OutageReminder {
  const OutageReminder({
    required this.kind,
    required this.at,
    required this.expected,
    required this.scheduled,
  });

  final ReminderKind kind;

  /// When to ask.
  final DateTime at;

  /// When the cut was expected to start or end; "Yes" logs this time.
  final DateTime expected;

  /// From the user's area schedule (else from the learned pattern).
  final bool scheduled;
}

/// Which reminders to set (ARCHITECTURE.md §5 F8 "Reminders"). At most one
/// question per expected cut, asked [delay] after it should have started,
/// over the next [days]; during a cut, one "Power back?" after it should
/// have ended (judged from when it started, so it is asked once, never
/// again later). Nothing already in the past, nothing for a cut already
/// logged.
List<OutageReminder> planReminders({
  required DateTime now,
  required List<OutageRecord> history,
  required List<ScheduleSlot> schedule,
  Duration delay = const Duration(minutes: 10),
  int days = 7,
  int max = 20,
}) {
  final local = now.toLocal();
  final windows = const OutagePattern().expectedWindows(
    now: local,
    hours: days * 24.0,
    history: history,
    schedule: schedule,
  );
  // Whether a time is a slot's start (that weekday) or end (any day: a
  // slot past midnight ends on the next one).
  bool isSlot(DateTime t, {required bool start}) {
    final minute = t.hour * 60 + t.minute;
    return schedule.any(
      (s) => start
          ? s.weekday == t.weekday && s.startMinute == minute
          : s.endMinute == minute,
    );
  }

  final ongoing = history.where((o) => o.end == null).firstOrNull;
  if (ongoing != null) {
    final current = const OutagePattern()
        .expectedWindows(
          now: ongoing.start,
          hours: days * 24.0,
          history: history,
          schedule: schedule,
        )
        .where((w) => !w.start.isAfter(ongoing.start))
        .firstOrNull;
    if (current == null) return const [];
    final at = current.end.add(delay);
    if (!at.isAfter(local)) return const [];
    return [
      OutageReminder(
        kind: ReminderKind.back,
        at: at,
        expected: current.end,
        scheduled: isSlot(current.end, start: false),
      ),
    ];
  }

  return [
    for (final w in windows)
      if (w.start.add(delay).isAfter(local))
        OutageReminder(
          kind: ReminderKind.cut,
          at: w.start.add(delay),
          expected: w.start,
          scheduled: isSlot(w.start, start: true),
        ),
  ].take(max).toList();
}
