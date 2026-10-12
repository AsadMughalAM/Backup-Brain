import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/locale/locale_controller.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/services/notification_inbox.dart';
import '../../../../core/services/preferences.dart';
import '../../../../core/utils/fire_and_forget.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/outage_notifier.dart';
import '../../domain/outage_outlook.dart';
import '../../domain/outage_repository.dart';
import '../../domain/reminder_plan.dart';

/// Asks for notification permission once, in context: the first time the
/// user logs a power cut (TECH_STACK.md §7.2 rule 7). Never nags.
class ReminderController {
  ReminderController(this._ref);

  final Ref _ref;

  static const _askedKey = 'notifications.asked';

  void askPermissionOnce() {
    final prefs = _ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_askedKey) ?? false) return;
    fireAndForget(prefs.setBool(_askedKey, true), 'notifications asked');
    fireAndForget(
      _ref.read(outageNotifierProvider).requestPermission(),
      'notification permission',
    );
  }
}

final reminderControllerProvider = Provider<ReminderController>(
  ReminderController.new,
);

/// Keeps the phone's notifications in step with the app: "Power gone?"
/// reminders follow the schedule and the log, the countdown notice follows
/// the battery, and a "Yes" on a reminder logs the event. Watched by the
/// app root for the whole session.
final outageNotificationsProvider = Provider<void>((ref) {
  final notifier = ref.watch(outageNotifierProvider);
  ReminderAnswer? pending;
  String? remindersKey;
  DateTime? countdownEndsAt;

  // An answer can arrive before the household has loaded (it opened the
  // app); it waits until the outlook is ready.
  void applyPending() {
    final answer = pending;
    if (answer == null || ref.read(outageOutlookProvider) == null) return;
    pending = null;
    final logger = ref.read(outageLoggerProvider);
    answer.powerWent
        ? logger.powerWent(at: answer.at)
        : logger.powerBack(at: answer.at);
  }

  fireAndForget(
    notifier.init((answer) {
      pending = answer;
      applyPending();
    }),
    'notifications init',
  );

  AppLocalizations l10n() =>
      lookupAppLocalizations(ref.read(localeProvider).locale);

  void syncReminders() {
    final outages = ref.read(recentOutagesProvider).value;
    final schedule = ref.read(scheduleProvider).value;
    if (outages == null || schedule == null) return;
    final now = ref.read(nowProvider).value ?? DateTime.now().toUtc();
    final reminders = planReminders(
      now: now,
      history: [for (final o in outages) o.record],
      schedule: [for (final e in schedule) e.slot],
    );
    final t = l10n();
    final key = [
      t.localeName,
      for (final r in reminders) '${r.kind.name}@${r.at.toIso8601String()}',
    ].join(',');
    if (key == remindersKey) return;
    remindersKey = key;
    final notices = [for (final r in reminders) _notice(t, r)];
    planInbox(
      ref,
      const {InboxKind.cutCheck, InboxKind.backCheck},
      [
        for (final (i, n) in notices.indexed)
          InboxEntry(
            kind: reminders[i].kind == ReminderKind.cut
                ? InboxKind.cutCheck
                : InboxKind.backCheck,
            at: n.at.toUtc(),
            title: n.title,
            body: n.body,
          ),
      ],
      now,
    );
    fireAndForget(
      notifier.setReminders(
        notices,
        channel: (
          name: t.notifChannelCheck,
          description: t.notifChannelCheckBody,
        ),
      ),
      'outage reminders',
    );
  }

  void syncCountdown(OutageOutlook? outlook) {
    final ongoing = outlook?.ongoing;
    if (outlook == null || ongoing == null || ongoing.backup.isUnlimited) {
      if (countdownEndsAt != null) {
        countdownEndsAt = null;
        fireAndForget(notifier.clearCountdown(), 'countdown clear');
      }
      return;
    }
    final now = ref.read(nowProvider).value ?? DateTime.now().toUtc();
    final left = Duration(
      minutes:
          (ongoing.backup.hours * 60 / _countdownStepMinutes).floor() *
          _countdownStepMinutes,
    );
    final endsAt = now.add(left);
    final last = countdownEndsAt;
    // Re-posting only for a real change keeps the notice from jumping.
    if (last != null && endsAt.difference(last).abs() < _countdownSlack) {
      return;
    }
    countdownEndsAt = endsAt;
    final t = l10n();
    fireAndForget(
      notifier.showCountdown(
        endsAt: endsAt,
        title: t.notifCountdownTitle(
          Formatters.localClock(ongoing.event.startedAt.toLocal()),
        ),
        body: t.notifCountdownBody(
          Formatters.duration(
            t,
            ongoing.backup.hours,
            stepMinutes: _countdownStepMinutes,
          ),
          Formatters.watts(outlook.loadW),
        ),
        channel: (
          name: t.notifChannelCountdown,
          description: t.notifChannelCountdownBody,
        ),
      ),
      'countdown',
    );
  }

  ref.listen(outageOutlookProvider, (_, outlook) {
    applyPending();
    syncCountdown(outlook);
  }, fireImmediately: true);
  ref.listen(recentOutagesProvider, (_, _) => syncReminders());
  ref.listen(scheduleProvider, (_, _) => syncReminders());
  ref.listen(nowProvider, (_, _) => syncReminders());
  ref.listen(localeProvider, (_, _) {
    remindersKey = null;
    countdownEndsAt = null;
    syncReminders();
    syncCountdown(ref.read(outageOutlookProvider));
  });
  syncReminders();
});

/// The countdown notice shows estimates to 10 minutes, like the app.
const _countdownStepMinutes = 10;
const _countdownSlack = Duration(minutes: 5);

ReminderNotice _notice(AppLocalizations t, OutageReminder r) {
  final time = Formatters.localClock(r.expected.toLocal());
  final cut = r.kind == ReminderKind.cut;
  return ReminderNotice(
    at: r.at,
    title: cut ? t.notifCutTitle : t.notifBackTitle,
    body: cut
        ? (r.scheduled ? t.notifCutScheduled(time) : t.notifCutLikely(time))
        : t.notifBackBody(time),
    yesLabel: cut ? t.notifCutYes : t.notifBackYes,
    noLabel: t.notifNo,
    payload: ReminderAnswer.payloadFor(powerWent: cut, at: r.expected),
  );
}
