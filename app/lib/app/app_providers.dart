import 'package:dio/dio.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/firebase_providers.dart';
import '../features/assistant/data/callable_assistant_repository.dart';
import '../features/assistant/domain/assistant_repository.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../core/services/demo_household_asset.dart';
import '../core/services/preferences.dart';
import '../features/backup/data/system_repository_impl.dart';
import '../features/backup/domain/system_repository.dart';
import '../features/loads/data/appliance_repository_impl.dart';
import '../features/loads/domain/appliance_repository.dart';
import '../features/setup/data/setup_draft_local_repository.dart';
import '../features/setup/data/setup_presets_asset_repository.dart';
import '../features/setup/domain/setup_draft_repository.dart';
import '../features/setup/domain/setup_presets_repository.dart';
import '../features/solar/data/sources/open_meteo_source.dart';
import '../features/solar/data/weather_repository_impl.dart';
import '../features/solar/domain/weather_repository.dart';

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
  authRepositoryProvider.overrideWith(
    (ref) => FirebaseAuthRepository(ref.watch(firebaseAuthProvider)),
  ),
  applianceRepositoryProvider.overrideWith(
    (ref) => FirestoreApplianceRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      loadDemoHouseholdAsset,
    ),
  ),
  setupDraftRepositoryProvider.overrideWithValue(
    LocalSetupDraftRepository(prefs),
  ),
  setupPresetsRepositoryProvider.overrideWithValue(
    const AssetSetupPresetsRepository(),
  ),
  weatherRepositoryProvider.overrideWith(
    (ref) => FirestoreWeatherRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      OpenMeteoSource(Dio(_weatherTimeouts)),
    ),
  ),
  assistantRepositoryProvider.overrideWith(
    (ref) => CallableAssistantRepository(
      FirebaseFunctions.instanceFor(region: 'asia-south1'),
    ),
  ),
];

// Give up quickly on a weak connection: the saved forecast stays on screen.
final _weatherTimeouts = BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
);
