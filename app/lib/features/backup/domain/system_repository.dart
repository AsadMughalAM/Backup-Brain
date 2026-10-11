import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/household_system.dart';

abstract interface class SystemRepository {
  /// The signed-in user's system; null when signed out or not set up yet.
  /// Emits from the offline cache first.
  Stream<HouseholdSystem?> watch();

  /// Not awaited by the UI: offline writes complete locally at once and
  /// sync later (TECH_STACK.md §7.2).
  Future<void> save(HouseholdSystem system);

  /// Saves a known charge (0–1) and when it was known. [checked] = the
  /// user read it off the UPS themselves.
  Future<void> setCharge(
    double soc, {
    required DateTime at,
    bool checked = false,
  });

  /// The user washed the panels at [at] (F3 soiling factor).
  Future<void> setPanelsCleaned(DateTime at);

  /// Writes the bundled demo household's system (Demo Mode).
  Future<void> loadDemo();

  /// Whether the signed-in user already has a system, asked of the server —
  /// never the cache, which is empty on a new phone. Throws when offline.
  Future<bool> existsOnServer();
}

/// Bound to the Firestore implementation in `app/app_providers.dart`.
final systemRepositoryProvider = Provider<SystemRepository>(
  (ref) => throw UnimplementedError('Overridden in app_providers.dart'),
);

/// Read by other features (dashboard, loads) — the only thing they import
/// from here.
final householdSystemProvider = StreamProvider<HouseholdSystem?>(
  (ref) => ref.watch(systemRepositoryProvider).watch(),
);
