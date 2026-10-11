import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/services/local_notifications.dart';
import '../domain/outage_notifier.dart';

/// [OutageNotifier] on Android with flutter_local_notifications. Reminders
/// are inexact alarms that may fire up to about an hour late in Doze; that
/// is fine for "did the power go?" and needs no exact-alarm permission.
class LocalOutageNotifier implements OutageNotifier {
  LocalOutageNotifier(this._notifications);

  final LocalNotifications _notifications;

  FlutterLocalNotificationsPlugin get _plugin => _notifications.plugin;

  static const _countdownId = 1;
  static const _firstReminderId = 100;

  /// Upper bound on reminders set at once (cancelled by id on replace).
  static const _maxReminders = 20;

  static const _yes = 'yes', _no = 'no';

  @override
  Future<void> init(void Function(ReminderAnswer answer) onAnswer) async {
    // "Yes" opens the app; the answer that launched it comes first. Lives
    // for the app's session, like the plugin.
    _notifications.responses().listen((response) {
      if (response.actionId != _yes) return;
      final answer = ReminderAnswer.parse(response.payload);
      if (answer != null) onAnswer(answer);
    });
  }

  @override
  Future<bool> requestPermission() => _notifications.requestPermission();

  @override
  Future<void> setReminders(
    List<ReminderNotice> notices, {
    required ChannelText channel,
  }) async {
    await _notifications.ready();
    for (var i = 0; i < _maxReminders; i++) {
      await _plugin.cancel(id: _firstReminderId + i);
    }
    for (final (i, n) in notices.take(_maxReminders).indexed) {
      await _plugin.zonedSchedule(
        id: _firstReminderId + i,
        scheduledDate: tz.TZDateTime.from(n.at.toUtc(), tz.UTC),
        title: n.title,
        body: n.body,
        payload: n.payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'outage_check',
            channel.name,
            channelDescription: channel.description,
            category: AndroidNotificationCategory.reminder,
            actions: [
              AndroidNotificationAction(
                _yes,
                n.yesLabel,
                showsUserInterface: true,
              ),
              AndroidNotificationAction(_no, n.noLabel),
            ],
          ),
        ),
      );
    }
  }

  @override
  Future<void> showCountdown({
    required DateTime endsAt,
    required String title,
    required String body,
    required ChannelText channel,
  }) async {
    final left = endsAt.difference(DateTime.now());
    if (left <= Duration.zero) return clearCountdown();
    await _notifications.ready();
    await _plugin.show(
      id: _countdownId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'backup_countdown',
          channel.name,
          channelDescription: channel.description,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: true,
          when: endsAt.millisecondsSinceEpoch,
          // The system ticks this down by itself; the app needn't run.
          usesChronometer: true,
          chronometerCountDown: true,
          timeoutAfter: left.inMilliseconds,
          category: AndroidNotificationCategory.status,
        ),
      ),
    );
  }

  @override
  Future<void> clearCountdown() async {
    await _notifications.ready();
    await _plugin.cancel(id: _countdownId);
  }
}

/// For platforms without local notifications (the web preview).
class NoOutageNotifier implements OutageNotifier {
  const NoOutageNotifier();

  @override
  Future<void> init(void Function(ReminderAnswer answer) onAnswer) async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> setReminders(
    List<ReminderNotice> notices, {
    required ChannelText channel,
  }) async {}

  @override
  Future<void> showCountdown({
    required DateTime endsAt,
    required String title,
    required String body,
    required ChannelText channel,
  }) async {}

  @override
  Future<void> clearCountdown() async {}
}
