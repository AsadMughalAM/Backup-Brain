import 'dart:math' as math;

import 'defaults.dart';

/// One logged outage, in the household's local wall-clock time.
final class OutageRecord {
  const OutageRecord({required this.start, this.end});

  final DateTime start;

  /// Null while the outage is still going on.
  final DateTime? end;

  double? get hours =>
      end == null ? null : end!.difference(start).inMinutes / 60;
}

/// A recurring outage the user entered from their area's schedule.
final class ScheduleSlot {
  const ScheduleSlot({
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  });

  /// `DateTime.monday` (1) … `DateTime.sunday` (7).
  final int weekday;

  /// Minutes after midnight, 0–1439. An end before the start means the
  /// outage runs past midnight.
  final int startMinute;
  final int endMinute;

  double get hours {
    final minutes = (endMinute - startMinute) % Duration.minutesPerDay;
    return (minutes == 0 ? Duration.minutesPerDay : minutes) / 60;
  }
}

enum PredictionSource { schedule, pattern }

final class OutagePrediction {
  const OutagePrediction({
    required this.start,
    required this.hours,
    required this.source,
    this.share,
    this.daysObserved,
  });

  final DateTime start;

  /// Expected length; null when no logged outage has ended yet.
  final double? hours;
  final PredictionSource source;

  /// Pattern only: share of observed days with an outage starting in this
  /// hour — the prediction's confidence.
  final double? share;

  /// Pattern only: how many days of logs it is based on.
  final int? daysObserved;
}

/// A stretch of time the power is expected to be off.
final class OutageWindow {
  const OutageWindow(this.start, this.end);

  final DateTime start;
  final DateTime end;

  /// Hours of this window inside [from]–[to].
  double hoursWithin(DateTime from, DateTime to) {
    final s = start.isAfter(from) ? start : from;
    final e = end.isBefore(to) ? end : to;
    return e.isAfter(s) ? e.difference(s).inSeconds / 3600 : 0;
  }
}

/// F8 — "When will the light go next?" (ARCHITECTURE.md §5 F8): the user's
/// schedule, and the household's own logged outages as a time-of-day
/// pattern. Whichever predicts the earlier outage wins, because published
/// schedules often don't match reality.
final class OutagePattern {
  const OutagePattern({
    this.lookbackDays = EngineDefaults.outageLookbackDays,
    this.minDays = EngineDefaults.outageMinDays,
    this.minShare = EngineDefaults.outageMinShare,
  });

  final int lookbackDays;
  final int minDays;
  final double minShare;

  /// The next outage after [now], or null when neither the schedule nor the
  /// logs say anything yet.
  OutagePrediction? next({
    required DateTime now,
    List<OutageRecord> history = const [],
    List<ScheduleSlot> schedule = const [],
  }) {
    final scheduled = nextScheduled(now, schedule);
    final learned = nextLearned(now, history);
    if (scheduled == null) return learned;
    if (learned == null) return scheduled;
    return learned.start.isBefore(scheduled.start) ? learned : scheduled;
  }

  OutagePrediction? nextScheduled(DateTime now, List<ScheduleSlot> schedule) {
    OutagePrediction? best;
    for (var d = 0; d <= DateTime.daysPerWeek; d++) {
      final day = DateTime(now.year, now.month, now.day + d);
      for (final slot in schedule.where((s) => s.weekday == day.weekday)) {
        final start = DateTime(
          day.year,
          day.month,
          day.day,
          0,
          slot.startMinute,
        );
        if (!start.isAfter(now)) continue;
        if (best == null || start.isBefore(best.start)) {
          best = OutagePrediction(
            start: start,
            hours: slot.hours,
            source: PredictionSource.schedule,
          );
        }
      }
      if (best != null) return best;
    }
    return null;
  }

  OutagePrediction? nextLearned(DateTime now, List<OutageRecord> history) {
    final since = DateTime(now.year, now.month, now.day - lookbackDays + 1);
    final recent = [
      for (final o in history)
        if (!o.start.isBefore(since) && o.start.isBefore(now)) o,
    ];
    if (recent.isEmpty) return null;

    final firstDay = recent.map((o) => _day(o.start)).reduce(_earlier);
    final daysObserved = math.min(
      lookbackDays,
      _day(now).difference(firstDay).inDays + 1,
    );
    if (daysObserved < minDays) return null;

    // Distinct days per start hour, so three cuts in one evening count once.
    final daysByHour = <int, Set<DateTime>>{};
    for (final o in recent) {
      daysByHour.putIfAbsent(o.start.hour, () => {}).add(_day(o.start));
    }

    for (var k = 0; k <= Duration.hoursPerDay; k++) {
      final slot = DateTime(now.year, now.month, now.day, now.hour + k);
      final days = daysByHour[slot.hour];
      if (days == null) continue;
      final share = days.length / daysObserved;
      if (share < minShare) continue;
      final inHour = recent.where((o) => o.start.hour == slot.hour).toList();
      final start = slot.add(
        Duration(minutes: _median(inHour.map((o) => o.start.minute)).round()),
      );
      if (!start.isAfter(now)) continue;
      return OutagePrediction(
        start: start,
        hours: _typicalHours(inHour) ?? _typicalHours(recent),
        source: PredictionSource.pattern,
        share: math.min(1.0, share),
        daysObserved: daysObserved,
      );
    }
    return null;
  }

  /// Every stretch the power is expected to be off in the [hours] after
  /// [now], merged where they overlap: the cut in progress (until its slot
  /// ends, else for the usual length, else
  /// [EngineDefaults.assumedOutageHours]), each scheduled slot, and the
  /// learned next outage. Used to drain the battery in the solar
  /// simulation (F3) when the panels make less than the house uses.
  List<OutageWindow> expectedWindows({
    required DateTime now,
    required double hours,
    List<OutageRecord> history = const [],
    List<ScheduleSlot> schedule = const [],
  }) {
    if (hours <= 0 || !hours.isFinite) {
      throw ArgumentError.value(hours, 'hours');
    }
    final until = now.add(Duration(minutes: (hours * 60).round()));
    final slots = _slotWindows(now, until, schedule);
    final windows = <OutageWindow>[...slots];

    final ongoing = history.where((o) => o.end == null).firstOrNull;
    if (ongoing != null) {
      final slot = slots
          .where(
            (w) =>
                !ongoing.start.isBefore(w.start.subtract(_slotEarly)) &&
                ongoing.start.isBefore(w.end),
          )
          .firstOrNull;
      final usual = _typicalHours(history) ?? EngineDefaults.assumedOutageHours;
      var end = slot?.end ?? ongoing.start.add(_hoursDuration(usual));
      if (!end.isAfter(now)) {
        end = now.add(_hoursDuration(EngineDefaults.assumedOutageHours));
      }
      windows.add(OutageWindow(ongoing.start, end));
    }

    final learned = nextLearned(now, history);
    if (learned != null) {
      final length = learned.hours ?? EngineDefaults.assumedOutageHours;
      windows.add(
        OutageWindow(learned.start, learned.start.add(_hoursDuration(length))),
      );
    }

    final inRange = [
      for (final w in windows)
        if (w.end.isAfter(now) && w.start.isBefore(until)) w,
    ]..sort((a, b) => a.start.compareTo(b.start));
    final merged = <OutageWindow>[];
    for (final w in inRange) {
      final last = merged.lastOrNull;
      if (last != null && !w.start.isAfter(last.end)) {
        merged[merged.length - 1] = OutageWindow(
          last.start,
          w.end.isAfter(last.end) ? w.end : last.end,
        );
      } else {
        merged.add(w);
      }
    }
    return merged;
  }

  /// A cut logged a little before its slot still belongs to it.
  static const _slotEarly = Duration(minutes: 30);

  static List<OutageWindow> _slotWindows(
    DateTime from,
    DateTime until,
    List<ScheduleSlot> schedule,
  ) {
    final windows = <OutageWindow>[];
    // From yesterday, so a slot running past midnight is included.
    for (
      var day = DateTime(from.year, from.month, from.day - 1);
      day.isBefore(until);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      for (final slot in schedule.where((s) => s.weekday == day.weekday)) {
        final start = DateTime(
          day.year,
          day.month,
          day.day,
          0,
          slot.startMinute,
        );
        windows.add(OutageWindow(start, start.add(_hoursDuration(slot.hours))));
      }
    }
    return windows;
  }

  static Duration _hoursDuration(double hours) =>
      Duration(minutes: (hours * 60).round());

  static double? _typicalHours(List<OutageRecord> outages) {
    final lengths = [
      for (final o in outages)
        if (o.hours case final h? when h > 0) h,
    ];
    return lengths.isEmpty ? null : _median(lengths);
  }

  static double _median(Iterable<num> values) {
    final sorted = values.toList()..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid].toDouble()
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

  static DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
