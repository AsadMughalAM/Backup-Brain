import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/firebase_providers.dart';
import '../core/services/demo_household_asset.dart';
import '../core/services/preferences.dart';
import '../features/backup/data/system_repository_impl.dart';
import '../features/backup/domain/system_repository.dart';
import '../features/loads/data/appliance_repository_impl.dart';
import '../features/loads/domain/appliance_repository.dart';
import '../features/solar/data/sources/open_meteo_source.dart';
import '../features/solar/data/weather_repository_impl.dart';
import '../features/solar/domain/weather_repository.dart';
import '../features/settings/data/firebase_auth_repository.dart';
import '../features/settings/domain/auth_repository.dart';

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
  weatherRepositoryProvider.overrideWith(
    (ref) => FirestoreWeatherRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      OpenMeteoSource(Dio(_weatherTimeouts)),
    ),
  ),
];

// Give up quickly on a weak connection: the saved forecast stays on screen.
final _weatherTimeouts = BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
);
