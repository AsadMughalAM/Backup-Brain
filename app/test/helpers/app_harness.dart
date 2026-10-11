import 'package:backup_brain/app/app.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/auth/domain/auth_repository.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
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
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(auth),
        systemRepositoryProvider.overrideWithValue(system),
        applianceRepositoryProvider.overrideWithValue(appliances),
        ...extra,
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

/// Intro → three "Next" taps → Sign up.
Future<void> goToSignUp(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
  }
}
