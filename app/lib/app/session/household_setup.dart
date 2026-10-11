import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/fire_and_forget.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/backup/domain/system_repository.dart';
import '../../features/loads/domain/appliance_repository.dart';

/// Gives every newly signed-in account a household, so sign-in lands on a
/// working dashboard. Until the full setup form exists, that household is
/// the demo one (ARCHITECTURE.md §12).
class HouseholdSetup {
  HouseholdSetup(this._ref);

  final Ref _ref;

  /// Seeds the demo household only if the server says this account has
  /// none. The server check matters: on a new phone the cache is empty, and
  /// trusting it would overwrite a returning user's real data.
  Future<void> ensure() async {
    final system = _ref.read(systemRepositoryProvider);
    try {
      if (await system.existsOnServer()) return;
    } catch (e) {
      // Offline or not signed in: try again next time (dashboard button or
      // next sign-in). Never seed blind.
      debugPrint('Household check skipped: $e');
      return;
    }
    // Appliances first, so the dashboard never shows the system with an
    // empty appliance list.
    fireAndForget(
      _ref.read(applianceRepositoryProvider).loadDemo(),
      'demo appliances',
    );
    fireAndForget(system.loadDemo(), 'demo system');
  }
}

/// Watched by the app root so it runs for the whole session: whenever a
/// real account signs in (or an anonymous one is upgraded), check once.
final householdSetupProvider = Provider<HouseholdSetup>((ref) {
  final setup = HouseholdSetup(ref);
  ref.listen<AsyncValue<AccountInfo?>>(accountProvider, (previous, next) {
    final now = next.value;
    final before = previous?.value;
    final becameSignedIn =
        now != null &&
        !now.isAnonymous &&
        (before == null || before.isAnonymous || before.uid != now.uid);
    if (becameSignedIn) setup.ensure();
  }, fireImmediately: true);
  return setup;
});
