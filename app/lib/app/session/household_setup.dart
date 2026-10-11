import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/fire_and_forget.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/backup/domain/system_repository.dart';
import '../../features/loads/domain/appliance_repository.dart';

enum HouseholdStatus {
  /// Not checked yet, or the check couldn't reach the server.
  unknown,
  exists,

  /// The server confirmed this account has no household: send it to setup.
  missing,
}

/// Whether the signed-in account already has a household. Only the server
/// can say "missing": on a new phone the cache is empty, and trusting it
/// would send a returning user through setup and overwrite their data.
class HouseholdSetup extends Notifier<HouseholdStatus> {
  @override
  HouseholdStatus build() {
    // Whenever a real account signs in (or an anonymous one is upgraded),
    // check once.
    ref.listen<AsyncValue<AccountInfo?>>(accountProvider, (previous, next) {
      final now = next.value;
      final before = previous?.value;
      final becameSignedIn =
          now != null &&
          !now.isAnonymous &&
          (before == null || before.isAnonymous || before.uid != now.uid);
      if (becameSignedIn) check();
    }, fireImmediately: true);
    return HouseholdStatus.unknown;
  }

  Future<void> check() async {
    try {
      final exists = await ref.read(systemRepositoryProvider).existsOnServer();
      state = exists ? HouseholdStatus.exists : HouseholdStatus.missing;
    } catch (e) {
      // Offline or not signed in: the dashboard offers setup or the demo,
      // and the next sign-in checks again. Never decide blind.
      debugPrint('Household check skipped: $e');
    }
  }

  /// Demo Mode (ARCHITECTURE.md §12), for exploring before entering a real
  /// setup. Appliances first, so the dashboard never shows the system with
  /// an empty appliance list.
  void useDemo() {
    fireAndForget(
      ref.read(applianceRepositoryProvider).loadDemo(),
      'demo appliances',
    );
    fireAndForget(ref.read(systemRepositoryProvider).loadDemo(), 'demo system');
  }
}

/// Watched by the app root so it lives for the whole session.
final householdSetupProvider =
    NotifierProvider<HouseholdSetup, HouseholdStatus>(HouseholdSetup.new);
