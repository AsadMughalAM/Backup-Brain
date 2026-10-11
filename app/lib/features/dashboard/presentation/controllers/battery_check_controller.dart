import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences.dart';
import '../../../../core/utils/fire_and_forget.dart';

/// The power cut whose battery question the user put off with "Not now".
/// Remembered on the phone, so the question doesn't come back for that cut,
/// even after a restart. The next cut may ask again.
class BatteryCheckDismissal extends Notifier<String?> {
  static const _key = 'batteryCheck.dismissedOutage';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  void dismiss(String outageId) {
    state = outageId;
    fireAndForget(
      ref.read(sharedPreferencesProvider).setString(_key, outageId),
      'battery check dismissed',
    );
  }
}

final batteryCheckDismissalProvider =
    NotifierProvider<BatteryCheckDismissal, String?>(BatteryCheckDismissal.new);
