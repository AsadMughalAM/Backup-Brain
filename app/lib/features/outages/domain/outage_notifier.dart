import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A reminder ready to post, with its words already in the user's language.
class ReminderNotice {
  const ReminderNotice({
    required this.at,
    required this.title,
    required this.body,
    required this.yesLabel,
    required this.noLabel,
    required this.payload,
  });

  final DateTime at;
  final String title;
  final String body;
  final String yesLabel;
  final String noLabel;

  /// Handed back when the user answers; see [ReminderAnswer.parse].
  final String payload;
}

/// An Android notification channel's name and description, which users
/// see in system settings (and can switch off there).
typedef ChannelText = ({String name, String description});

/// The user tapped "Yes" on a reminder: log a cut or its end at [at].
class ReminderAnswer {
  const ReminderAnswer({required this.powerWent, required this.at});

  final bool powerWent;
  final DateTime at;

  static const _cut = 'cut', _back = 'back';

  static String payloadFor({required bool powerWent, required DateTime at}) =>
      '${powerWent ? _cut : _back}|${at.toUtc().toIso8601String()}';

  /// Null for anything that isn't a reminder's payload.
  static ReminderAnswer? parse(String? payload) {
    final parts = payload?.split('|');
    if (parts == null || parts.length != 2) return null;
    final at = DateTime.tryParse(parts[1]);
    if (at == null || (parts[0] != _cut && parts[0] != _back)) return null;
    return ReminderAnswer(powerWent: parts[0] == _cut, at: at);
  }
}

/// Local notifications for outages (TECH_STACK.md §7.2 rule 7): scheduled
/// on the phone, so they work in airplane mode.
abstract interface class OutageNotifier {
  /// [onAnswer] gets every "Yes", including the one that opened the app.
  Future<void> init(void Function(ReminderAnswer answer) onAnswer);

  /// Asks Android 13+ for permission to post. True when allowed.
  Future<bool> requestPermission();

  /// Replaces every reminder set before with [notices].
  Future<void> setReminders(
    List<ReminderNotice> notices, {
    required ChannelText channel,
  });

  /// The ongoing "Power cut since 8:00 PM" notice that counts down to
  /// [endsAt] by itself, without the app running. Replaces the last one.
  Future<void> showCountdown({
    required DateTime endsAt,
    required String title,
    required String body,
    required ChannelText channel,
  });

  Future<void> clearCountdown();
}

/// Bound in `app/app_providers.dart`: the plugin on Android, a no-op
/// elsewhere (the web preview).
final outageNotifierProvider = Provider<OutageNotifier>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);
