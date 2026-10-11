import 'package:energy_engine/energy_engine.dart';
import 'package:test/test.dart';

/// Sunday 11 Oct 2026, 3 PM.
final now = DateTime(2026, 10, 11, 15);

/// An outage [daysAgo] days before [now], at [hour]:[minute] for [hours].
OutageRecord cut(int daysAgo, int hour, int minute, double hours) {
  final start = DateTime(now.year, now.month, now.day - daysAgo, hour, minute);
  return OutageRecord(
    start: start,
    end: start.add(Duration(minutes: (hours * 60).round())),
  );
}

void main() {
  const pattern = OutagePattern();

  group('learned pattern', () {
    test('an evening cut on every logged day predicts tonight', () {
      final history = [for (var d = 1; d <= 5; d++) cut(d, 19, 10, 1.5)];
      final next = pattern.next(now: now, history: history)!;
      expect(next.start, DateTime(2026, 10, 11, 19, 10));
      expect(next.hours, 1.5);
      expect(next.source, PredictionSource.pattern);
      expect(next.daysObserved, 6); // five logged days + today
      expect(next.share, closeTo(5 / 6, 1e-9));
    });

    test('two cuts in one evening count as one day', () {
      final history = [
        cut(1, 19, 0, 1),
        cut(1, 19, 40, 0.5),
        cut(2, 19, 0, 1),
        cut(3, 19, 0, 1),
      ];
      expect(pattern.next(now: now, history: history)!.share, 3 / 4);
    });

    test('too few days of logs is not a pattern', () {
      final history = [cut(0, 9, 0, 1), cut(1, 19, 0, 1)];
      expect(pattern.next(now: now, history: history), isNull);
    });

    test('a one-off cut does not become a prediction', () {
      final history = [
        cut(9, 8, 0, 1),
        for (var d = 1; d <= 4; d++) cut(d, 19, 0, 1),
      ];
      final next = pattern.next(now: now, history: history)!;
      expect(next.start.hour, 19, reason: '08:00 happened on 1 of 10 days');
    });

    test('an hour already passed today rolls to tomorrow', () {
      final history = [for (var d = 1; d <= 4; d++) cut(d, 9, 30, 2)];
      expect(
        pattern.next(now: now, history: history)!.start,
        DateTime(2026, 10, 12, 9, 30),
      );
    });

    test('logs older than the lookback are ignored', () {
      final history = [for (var d = 20; d <= 25; d++) cut(d, 19, 0, 1)];
      expect(pattern.next(now: now, history: history), isNull);
    });

    test('an outage still going on gives no length', () {
      final history = [
        for (var d = 1; d <= 3; d++)
          OutageRecord(start: DateTime(2026, 10, 11 - d, 19)),
      ];
      expect(pattern.next(now: now, history: history)!.hours, isNull);
    });
  });

  group('schedule', () {
    test('the next scheduled slot, with its length', () {
      const slots = [
        ScheduleSlot(
          weekday: DateTime.sunday,
          startMinute: 17 * 60,
          endMinute: 18 * 60,
        ),
      ];
      final next = pattern.next(now: now, schedule: slots)!;
      expect(next.start, DateTime(2026, 10, 11, 17));
      expect(next.hours, 1);
      expect(next.source, PredictionSource.schedule);
    });

    test('a slot past midnight lasts into the next day', () {
      const slot = ScheduleSlot(
        weekday: DateTime.monday,
        startMinute: 23 * 60,
        endMinute: 60,
      );
      expect(slot.hours, 2);
    });

    test('a slot already over today comes round next week', () {
      const slots = [
        ScheduleSlot(
          weekday: DateTime.sunday,
          startMinute: 8 * 60,
          endMinute: 9 * 60,
        ),
      ];
      expect(
        pattern.next(now: now, schedule: slots)!.start,
        DateTime(2026, 10, 18, 8),
      );
    });

    test('the earlier of schedule and pattern wins', () {
      final history = [for (var d = 1; d <= 5; d++) cut(d, 16, 0, 1)];
      const slots = [
        ScheduleSlot(
          weekday: DateTime.sunday,
          startMinute: 19 * 60,
          endMinute: 20 * 60,
        ),
      ];
      final next = pattern.next(now: now, history: history, schedule: slots)!;
      expect(next.source, PredictionSource.pattern);
      expect(next.start, DateTime(2026, 10, 11, 16));
    });
  });
}
