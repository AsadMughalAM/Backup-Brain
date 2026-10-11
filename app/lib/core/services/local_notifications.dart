import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

/// The one owner of `flutter_local_notifications`. The plugin is a
/// singleton: a second `initialize` would replace the first one's tap
/// handler, so every notification feature (the F8 heads-up, the "Power
/// gone?" reminders, the countdown) goes through this and picks out its
/// own taps by payload.
class LocalNotifications {
  final plugin = FlutterLocalNotificationsPlugin();
  final _responses = StreamController<NotificationResponse>.broadcast();
  Future<void>? _ready;
  NotificationResponse? _launch;

  Future<void> ready() => _ready ??= _init();

  Future<void> _init() async {
    // Notification times are absolute instants: UTC is the only zone used.
    tz_data.initializeTimeZones();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _responses.add,
      onDidReceiveBackgroundNotificationResponse: _ignoreInBackground,
    );
    final launch = await plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _launch = launch?.notificationResponse;
    }
  }

  /// Every tap and action, starting with the one that opened the app (each
  /// listener gets it, and ignores it if it isn't theirs).
  Stream<NotificationResponse> responses() async* {
    await ready();
    final launch = _launch;
    if (launch != null) yield launch;
    yield* _responses.stream;
  }

  /// Asks Android 13+ once; true when allowed.
  Future<bool> requestPermission() async {
    await ready();
    return await plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        true;
  }
}

/// Actions that don't open the app ("No") need nothing done, but the
/// plugin requires a handler for them.
@pragma('vm:entry-point')
void _ignoreInBackground(NotificationResponse response) {
  debugPrint('Notification action in background: ${response.actionId}');
}

/// Android only; web and tests use no-op schedulers instead.
bool get localNotificationsSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
