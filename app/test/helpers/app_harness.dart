import 'package:backup_brain/app/app.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/auth/domain/auth_repository.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:backup_brain/features/setup/data/setup_draft_local_repository.dart';
import 'package:backup_brain/features/setup/domain/setup_draft_repository.dart';
import 'package:backup_brain/features/setup/domain/setup_presets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  required FakeSystemRepository system,
  required FakeApplianceRepository appliances,
  // What the phone already has saved, e.g. a half-finished setup.
  Map<String, Object> saved = const {},
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
        setupDraftRepositoryProvider.overrideWithValue(
          LocalSetupDraftRepository(prefs),
        ),
        setupPresetsRepositoryProvider.overrideWithValue(
          const FileSetupPresetsRepository(),
        ),
      ],
      child: const App(),
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
