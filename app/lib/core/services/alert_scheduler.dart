import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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

/// `flutter_local_notifications` on Android.
class LocalAlertScheduler implements AlertScheduler {
  LocalAlertScheduler({required this.channelName});

  /// Shown in Android's notification settings.
  final String channelName;

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<void>.broadcast();
  Future<void>? _ready;
  bool? _allowed;

  static const _id = 8; // F8: one outage alert at a time.
  static const _channelId = 'outage_alerts';

  Future<void> _init() async {
    // Alert times are absolute instants, so UTC is the only zone needed.
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) => _taps.add(null),
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) _taps.add(null);
  }

  Future<void> _ensureReady() => _ready ??= _init();

  @override
  Stream<void> get taps {
    unawaited(_ensureReady());
    return _taps.stream;
  }

  @override
  Future<void> schedule({
    required DateTime atUtc,
    required String title,
    required String body,
  }) async {
    await _ensureReady();
    // Android 13+ asks once; a "no" is respected until changed in settings.
    _allowed ??=
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        true;
    if (_allowed == false) return;
    await _plugin.zonedSchedule(
      id: _id,
      scheduledDate: tz.TZDateTime.from(atUtc, tz.UTC),
      title: title,
      body: body,
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
    await _ensureReady();
    await _plugin.cancel(id: _id);
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

bool get alertsSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
