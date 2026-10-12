import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/firebase/firebase_providers.dart';
import '../core/services/alert_scheduler.dart';
import '../core/services/local_notifications.dart';
import '../features/assistant/data/callable_assistant_repository.dart';
import '../features/assistant/data/gemini_direct_assistant_repository.dart';
import '../features/assistant/domain/assistant_repository.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../core/services/demo_household_asset.dart';
import '../core/services/preferences.dart';
import '../features/backup/data/system_repository_impl.dart';
import '../features/backup/domain/system_repository.dart';
import '../features/loads/data/appliance_repository_impl.dart';
import '../features/battery/data/battery_catalog_repository_impl.dart';
import '../features/battery/data/geoapify_shops_repository.dart';
import '../features/battery/domain/battery_catalog_repository.dart';
import '../features/battery/domain/nearby_shops_repository.dart';
import '../features/estimator/data/pricing_repository_impl.dart';
import '../features/estimator/domain/pricing_repository.dart';
import '../features/loads/domain/appliance_repository.dart';
import '../features/outages/data/local_outage_notifier.dart';
import '../features/outages/data/outage_repository_impl.dart';
import '../features/outages/domain/outage_notifier.dart';
import '../features/outages/domain/outage_repository.dart';
import '../features/setup/data/device_home_locator.dart';
import '../features/setup/data/geoapify_place_names.dart';
import '../features/setup/data/setup_draft_local_repository.dart';
import '../features/setup/data/setup_presets_asset_repository.dart';
import '../features/setup/domain/home_locator.dart';
import '../features/setup/domain/setup_draft_repository.dart';
import '../features/setup/domain/setup_presets_repository.dart';
import '../features/solar/data/solar_log_repository_impl.dart';
import '../features/solar/data/sources/open_meteo_source.dart';
import '../features/solar/domain/solar_log_repository.dart';
import '../features/solar/data/weather_repository_impl.dart';
import '../features/solar/domain/weather_repository.dart';
import 'l10n/app_localizations.dart';
import 'locale/locale_controller.dart';

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
  homeLocatorProvider.overrideWithValue(
    DeviceHomeLocator(
      placeNames: _geoapifyKey.isEmpty
          ? null
          : GeoapifyPlaceNames(Dio(_quickTimeouts), apiKey: _geoapifyKey),
    ),
  ),
  weatherRepositoryProvider.overrideWith(
    (ref) => FirestoreWeatherRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
      OpenMeteoSource(Dio(_quickTimeouts)),
    ),
  ),
  alertSchedulerProvider.overrideWith(
    (ref) => localNotificationsSupported
        ? LocalAlertScheduler(
            _notifications,
            channelName: lookupAppLocalizations(ref.read(localeProvider).locale)
                .alertChannelName,
          )
        : const NoAlertScheduler(),
  ),
  batteryCatalogRepositoryProvider.overrideWithValue(
    const AssetBatteryCatalogRepository(),
  ),
  if (_geoapifyKey.isNotEmpty)
    nearbyShopsRepositoryProvider.overrideWithValue(
      GeoapifyShopsRepository(Dio(_quickTimeouts), apiKey: _geoapifyKey),
    ),
  pricingRepositoryProvider.overrideWith(
    (ref) => ConfigPricingRepository(ref.watch(firestoreProvider)),
  ),
  solarLogRepositoryProvider.overrideWith(
    (ref) => FirestoreSolarLogRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
    ),
  ),
  outageRepositoryProvider.overrideWith(
    (ref) => FirestoreOutageRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseAuthProvider),
    ),
  ),
  outageNotifierProvider.overrideWithValue(
    localNotificationsSupported
        ? LocalOutageNotifier(_notifications)
        : const NoOutageNotifier(),
  ),
  assistantRepositoryProvider.overrideWith(
    (ref) => _geminiKey.isNotEmpty
        ? GeminiDirectAssistantRepository(
            Dio(_aiTimeouts),
            prefs,
            apiKey: _geminiKey,
          )
        : _callableAssistant(),
  ),
];

/// MVP (docs/decisions/0002): `flutter run --dart-define-from-file=env.json`
/// with `GEMINI_API_KEY` in the git-ignored `env.json`. Empty = use the
/// `assistantChat` Cloud Function instead.
const _geminiKey = String.fromEnvironment('GEMINI_API_KEY');

/// MVP (docs/decisions/0003): Geoapify key for F7 nearby shops and setup's
/// area lookup, from the same `env.json`. Empty = only the Google Maps
/// search link, and "Use my location" picks the nearest city without the
/// area.
const _geoapifyKey = String.fromEnvironment('GEOAPIFY_API_KEY');

// The usual cause of "assistant isn't available": the app was started
// without env.json, so the key is empty and the undeployed function is used.
AssistantRepository _callableAssistant() {
  log(
    'GEMINI_API_KEY is empty in this build, so the assistant uses the '
    'assistantChat Cloud Function. To call Gemini directly, run '
    '`flutter run --dart-define-from-file=env.json`.',
    name: 'assistant',
  );
  return CallableAssistantRepository(
    FirebaseFunctions.instanceFor(region: 'asia-south1'),
  );
}

final _aiTimeouts = BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 40),
);

// Give up quickly on a weak connection: the saved forecast (or the Google
// Maps link for shops) stays on screen.
final _quickTimeouts = BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
);

/// The app's one notification plugin owner, shared by every notification
/// feature (see `LocalNotifications`).
final _notifications = LocalNotifications();
