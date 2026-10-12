import 'package:backup_brain/app/app.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/auth/domain/auth_repository.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/battery/domain/battery_catalog_repository.dart';
import 'package:backup_brain/features/estimator/domain/pricing_repository.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:backup_brain/features/outages/domain/outage_notifier.dart';
import 'package:backup_brain/features/outages/domain/outage_repository.dart';
import 'package:backup_brain/features/setup/data/setup_draft_local_repository.dart';
import 'package:backup_brain/features/solar/domain/solar_log_repository.dart';
import 'package:backup_brain/features/setup/domain/setup_draft_repository.dart';
import 'package:backup_brain/features/setup/domain/setup_presets_repository.dart';
import 'package:backup_brain/features/solar/domain/weather_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  required FakeSystemRepository system,
  required FakeApplianceRepository appliances,
  FakeOutageRepository? outages,
  FakeOutageNotifier? notifier,
  FakeSolarLogRepository? solarLogs,
  FakeWeatherRepository? weather,
  // What the phone already has saved, e.g. a half-finished setup.
  Map<String, Object> saved = const {},
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(saved);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth),
        systemRepositoryProvider.overrideWithValue(system),
        applianceRepositoryProvider.overrideWithValue(appliances),
        pricingRepositoryProvider.overrideWithValue(FakePricingRepository()),
        solarLogRepositoryProvider.overrideWithValue(
          solarLogs ?? FakeSolarLogRepository(),
        ),
        batteryCatalogRepositoryProvider.overrideWithValue(
          FakeBatteryCatalogRepository(),
        ),
        outageRepositoryProvider.overrideWithValue(
          outages ?? FakeOutageRepository(),
        ),
        outageNotifierProvider.overrideWithValue(
          notifier ?? FakeOutageNotifier(),
        ),
        setupDraftRepositoryProvider.overrideWithValue(
          LocalSetupDraftRepository(prefs),
        ),
        // No saved forecast and no network, unless a test says otherwise.
        weatherRepositoryProvider.overrideWithValue(
          weather ?? FakeWeatherRepository(),
        ),
        setupPresetsRepositoryProvider.overrideWithValue(
          const FileSetupPresetsRepository(),
        ),
        ...extra,
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

/// The page's own list. A text field has a Scrollable too (sideways), so
/// "the last Scrollable" can be a field.
Finder get pageScroll => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .last;

/// Setup's city: open the picker, search, pick.
Future<void> pickCity(WidgetTester tester, String city) async {
  await tester.ensureVisible(find.text('Pick your city'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pick your city'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(EditableText),
    ),
    city,
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byWidgetPredicate((w) => w is Text && w.data == city),
    ),
  );
  await tester.pumpAndSettle();
}

Finder field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(TextField)),
  matching: find.byType(EditableText),
);

/// First open is setup; returning users go Login → "Create an account".
Future<void> goToSignUp(WidgetTester tester) async {
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Create an account'));
  await tester.pumpAndSettle();
}

/// Everything saved on the (fake) phone, to start the app again with it.
Future<Map<String, Object>> savedOnPhone() async {
  final prefs = await SharedPreferences.getInstance();
  return {for (final k in prefs.getKeys()) k: prefs.get(k)!};
}
