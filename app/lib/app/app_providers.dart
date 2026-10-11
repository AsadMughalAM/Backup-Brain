import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/firebase_providers.dart';
import '../core/services/demo_household_asset.dart';
import '../core/services/preferences.dart';
import '../features/backup/data/system_repository_impl.dart';
import '../features/backup/domain/system_repository.dart';
import '../features/loads/data/appliance_repository_impl.dart';
import '../features/loads/domain/appliance_repository.dart';

/// Composition root: binds each repository interface to its implementation.
/// Tests pass their own overrides instead.
List<Override> appOverrides(SharedPreferences prefs) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  systemRepositoryProvider.overrideWith(
    (ref) => FirestoreSystemRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      loadDemoHouseholdAsset,
    ),
  ),
  applianceRepositoryProvider.overrideWith(
    (ref) => FirestoreApplianceRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      loadDemoHouseholdAsset,
    ),
  ),
];
