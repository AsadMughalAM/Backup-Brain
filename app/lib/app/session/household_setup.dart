import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/fire_and_forget.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/backup/domain/entities/household_system.dart';
import '../../features/backup/domain/system_repository.dart';
import '../../features/loads/domain/appliance_repository.dart';
import '../../features/loads/domain/entities/appliance.dart';
import '../../features/setup/domain/setup_draft_repository.dart';
import '../../features/setup/domain/setup_presets_repository.dart';
import '../locale/locale_controller.dart';

enum HouseholdStatus {
  /// Not checked yet, or the check couldn't reach the server.
  unknown,
  exists,

  /// The server confirmed this account has no household and the phone has
  /// no finished setup for it: send it to setup.
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
      if (exists) {
        // The account's saved home wins over answers given on this phone
        // while signed out; never overwrite it.
        await ref.read(setupDraftRepositoryProvider).clear();
        state = HouseholdStatus.exists;
        return;
      }
      state = await adoptLocalHome()
          ? HouseholdStatus.exists
          : HouseholdStatus.missing;
    } catch (e) {
      // Offline or not signed in: the dashboard offers setup or the demo,
      // and the next sign-in checks again. Never decide blind.
      debugPrint('Household check skipped: $e');
    }
  }

  /// Saves the setup finished on this phone as the signed-in account's
  /// household, then forgets the local copy. False when there is no
  /// finished setup to save.
  Future<bool> adoptLocalHome() async {
    final drafts = ref.read(setupDraftRepositoryProvider);
    final draft = drafts.load();
    if (draft == null ||
        !draft.finished ||
        !draft.homeDone ||
        !draft.batteryDone) {
      return false;
    }
    final presets = await ref.read(setupPresetsProvider.future);
    final language = ref.read(localeProvider).locale.languageCode;
    saveHome(
      draft.toSystem(presets, answeredAt: DateTime.now().toUtc()),
      draft.toAppliances(presets, language),
    );
    await drafts.clear();
    return true;
  }

  /// Writes a household from setup or "Edit my home". [replacing] are the
  /// account's appliances the new list takes the place of. Not awaited:
  /// the offline cache has the writes at once and the screens follow it.
  void saveHome(
    HouseholdSystem system,
    List<Appliance> appliances, {
    Set<String> replacing = const {},
  }) {
    // Appliances first, so the dashboard never shows the system with an
    // empty appliance list.
    fireAndForget(
      ref
          .read(applianceRepositoryProvider)
          .addAll(appliances, removing: replacing),
      'home appliances',
    );
    fireAndForget(
      ref.read(systemRepositoryProvider).save(system),
      'home system',
    );
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
