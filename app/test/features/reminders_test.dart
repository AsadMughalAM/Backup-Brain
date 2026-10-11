import 'package:backup_brain/core/services/clock.dart';
import 'package:backup_brain/features/outages/domain/outage_notifier.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:backup_brain/features/outages/domain/reminder_plan.dart';
import 'package:energy_engine/energy_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// 3 PM local on Sunday 11 Oct 2026.
final _threePm = DateTime(2026, 10, 11, 15);

/// Sunday 7–9 PM, as the user entered it from their area's schedule.
const _evening = ScheduleSlot(
  weekday: DateTime.sunday,
  startMinute: 19 * 60,
  endMinute: 21 * 60,
);

void main() {
  group('which reminders', () {
    test('one question 10 min after each scheduled cut, none in the past', () {
      final reminders = planReminders(
        now: _threePm,
        history: const [],
        schedule: const [_evening],
        days: 2,
      );
      expect(reminders.first.kind, ReminderKind.cut);
      expect(reminders.first.at, DateTime(2026, 10, 11, 19, 10));
      expect(reminders.first.expected, DateTime(2026, 10, 11, 19));
      expect(reminders.first.scheduled, isTrue);
      // Next Sunday is beyond two days.
      expect(reminders, hasLength(1));
    });

    test('nothing to ask without a schedule or a pattern', () {
      expect(
        planReminders(now: _threePm, history: const [], schedule: const []),
        isEmpty,
      );
    });

    test('a learned evening cut is asked about as "usually"', () {
      final history = [
        for (var d = 1; d <= 5; d++)
          OutageRecord(
            start: DateTime(2026, 10, 11 - d, 18),
            end: DateTime(2026, 10, 11 - d, 19),
          ),
      ];
      final first = planReminders(
        now: _threePm,
        history: history,
        schedule: const [],
      ).first;
      expect(first.expected, DateTime(2026, 10, 11, 18));
      expect(first.scheduled, isFalse);
    });

    test('during a cut: only "Power back?" after it should have ended', () {
      final reminders = planReminders(
        now: DateTime(2026, 10, 11, 19, 30),
        history: [OutageRecord(start: DateTime(2026, 10, 11, 19, 5))],
        schedule: const [_evening],
      );
      expect(reminders, hasLength(1));
      expect(reminders.single.kind, ReminderKind.back);
      expect(reminders.single.at, DateTime(2026, 10, 11, 21, 10));
      expect(reminders.single.scheduled, isTrue);
    });

    test('a cut already past its expected end asks nothing more', () {
      expect(
        planReminders(
          now: DateTime(2026, 10, 11, 23),
          history: [OutageRecord(start: DateTime(2026, 10, 11, 19))],
          schedule: const [_evening],
        ),
        isEmpty,
      );
    });

    test('never more than the limit', () {
      final every = [
        for (var d = 1; d <= 7; d++)
          for (var h = 0; h < 24; h += 2)
            ScheduleSlot(
              weekday: d,
              startMinute: h * 60,
              endMinute: h * 60 + 60,
            ),
      ];
      expect(
        planReminders(now: _threePm, history: const [], schedule: every),
        hasLength(20),
      );
    });
  });

  group('reminder answers', () {
    test('round-trip through the notification payload', () {
      final at = DateTime.utc(2026, 10, 11, 14);
      final answer = ReminderAnswer.parse(
        ReminderAnswer.payloadFor(powerWent: true, at: at),
      )!;
      expect(answer.powerWent, isTrue);
      expect(answer.at, at);
      expect(ReminderAnswer.parse('nonsense'), isNull);
      expect(ReminderAnswer.parse(null), isNull);
    });
  });

  testWidgets('reminders follow the schedule; "Yes" logs the cut from the '
      'scheduled time, the countdown notice follows the battery, and '
      '"Power back" clears it', (tester) async {
    final clock = TestClock(_threePm);
    final notifier = FakeOutageNotifier();
    final outages = FakeOutageRepository(
      schedule: const [ScheduleEntry('s1', _evening)],
    );
    await pumpApp(
      tester,
      auth: FakeAuthRepository(account: signedInAsAsad),
      system: FakeSystemRepository(demoSystem()),
      appliances: FakeApplianceRepository(demoAppliances()),
      outages: outages,
      notifier: notifier,
      extra: [nowProvider.overrideWith((ref) => clock.stream())],
    );

    final first = notifier.reminders.first;
    expect(first.title, 'Power gone?');
    expect(first.body, 'Your schedule says 7:00 PM. Tap if the power went.');
    expect(first.yesLabel, 'Yes, it went');
    expect(first.at, DateTime(2026, 10, 11, 19, 10));
    expect(notifier.countdown, isNull);

    // 7:25 PM: the user taps "Yes, it went" on the notification.
    clock.advance(const Duration(hours: 4, minutes: 25));
    await tester.pumpAndSettle();
    notifier.answer(ReminderAnswer.parse(first.payload)!);
    await tester.pumpAndSettle();

    final cut = outages.outages.single;
    expect(cut.startedAt.toLocal(), DateTime(2026, 10, 11, 19));
    expect(cut.isOngoing, isTrue);
    expect(notifier.countdown!.title, 'Power cut since 7:00 PM');
    expect(notifier.countdown!.body, startsWith('Backup about '));
    expect(notifier.reminders.single.title, 'Power back?');
    final back = notifier.reminders.single;
    expect(back.body, 'It usually comes back by 9:00 PM.');

    // Answering "Power back?" at 9:15 logs the end at 9 PM, and nothing
    // asks again.
    clock.advance(const Duration(hours: 1, minutes: 50));
    await tester.pumpAndSettle();
    expect(notifier.reminders, isEmpty);
    notifier.answer(ReminderAnswer.parse(back.payload)!);
    await tester.pumpAndSettle();
    expect(
      outages.outages.single.endedAt!.toLocal(),
      DateTime(2026, 10, 11, 21),
    );
    expect(notifier.countdown, isNull);
  });

  testWidgets('notification permission is asked once, at the first logged '
      'cut', (tester) async {
    final notifier = FakeOutageNotifier();
    await pumpApp(
      tester,
      auth: FakeAuthRepository(account: signedInAsAsad),
      system: FakeSystemRepository(demoSystem()),
      appliances: FakeApplianceRepository(demoAppliances()),
      notifier: notifier,
    );
    expect(notifier.permissionRequests, 0);
    await tester.tap(find.text('Power gone?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Power back?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Power gone?'));
    await tester.pumpAndSettle();
    expect(notifier.permissionRequests, 1);
  });
}
