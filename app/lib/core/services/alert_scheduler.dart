import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'local_notifications.dart';

/// One pending outage alert at a time, shown by the phone itself so it
/// fires offline (TECH_STACK.md §7.2 rule 7).
abstract interface class AlertScheduler {
  /// Replaces any pending alert.
  Future<void> schedule({
    required DateTime atUtc,
    required String title,
    required String body,
  });

  Future<void> cancel();

  /// Fires when the user taps an alert, including the one that opened the
  /// app.
  Stream<void> get taps;
}

/// Web and tests: alerts are an Android feature.
class NoAlertScheduler implements AlertScheduler {
  const NoAlertScheduler();

  @override
  Future<void> schedule({
    required DateTime atUtc,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel() async {}

  @override
  Stream<void> get taps => const Stream.empty();
}

/// `flutter_local_notifications` on Android, through the app's one
/// [LocalNotifications] owner.
class LocalAlertScheduler implements AlertScheduler {
  LocalAlertScheduler(this._notifications, {required this.channelName});

  final LocalNotifications _notifications;

  /// Shown in Android's notification settings.
  final String channelName;

  bool? _allowed;

  static const _id = 8; // F8: one outage alert at a time.
  static const _channelId = 'outage_alerts';

  /// Marks this feature's notifications, so other notification taps (the
  /// "Power gone?" reminders) don't open the Outages screen twice.
  static const _payload = 'outage_alert';

  @override
  Stream<void> get taps => _notifications.responses().where(
    (r) => r.payload == _payload && r.actionId == null,
  );

  @override
  Future<void> schedule({
    required DateTime atUtc,
    required String title,
    required String body,
  }) async {
    // Android 13+ asks once; a "no" is respected until changed in settings.
    _allowed ??= await _notifications.requestPermission();
    if (_allowed == false) return;
    await _notifications.plugin.zonedSchedule(
      id: _id,
      scheduledDate: tz.TZDateTime.from(atUtc, tz.UTC),
      title: title,
      body: body,
      payload: _payload,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      // A heads-up a few minutes late is fine; exact alarms would need an
      // extra permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel() async {
    await _notifications.ready();
    await _notifications.plugin.cancel(id: _id);
  }
}

/// Bound in `app/app_providers.dart`: local notifications on Android,
/// nothing elsewhere.
final alertSchedulerProvider = Provider<AlertScheduler>(
  (ref) => const NoAlertScheduler(),
);

/// Counts taps so that every tap is a new value for listeners.
final alertTapsProvider = StreamProvider<int>((ref) {
  var taps = 0;
  return ref.watch(alertSchedulerProvider).taps.map((_) => ++taps);
});
