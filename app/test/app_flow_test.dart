import 'package:backup_brain/app/app.dart';
import 'package:backup_brain/core/services/preferences.dart';
import 'package:backup_brain/features/backup/domain/system_repository.dart';
import 'package:backup_brain/features/loads/domain/appliance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  required FakeSystemRepository system,
  required FakeApplianceRepository appliances,
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
        systemRepositoryProvider.overrideWithValue(system),
        applianceRepositoryProvider.overrideWithValue(appliances),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('demo household: dashboard shows the §12 hook number', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      system: FakeSystemRepository(demoSystem()),
      appliances: FakeApplianceRepository(demoAppliances()),
    );
    expect(find.text('3h 28m'), findsOneWidget);
    expect(find.text('left at 420 W'), findsOneWidget);
    // Actionable advice from the engine's top suggestion.
    expect(find.textContaining('Turn off LED TV'), findsOneWidget);
  });

  testWidgets('load planner: turning off TV and fridge gives 5h 49m', (
    tester,
  ) async {
    final appliances = FakeApplianceRepository(demoAppliances());
    await _pumpApp(
      tester,
      system: FakeSystemRepository(demoSystem()),
      appliances: appliances,
    );
    await tester.tap(find.text('What should I turn off?'));
    await tester.pumpAndSettle();
    expect(find.text('Load planner'), findsOneWidget);

    await appliances.setOn('tv', isOn: false);
    await appliances.setOn('fridge', isOn: false);
    await tester.pumpAndSettle();
    expect(find.text('5h 49m'), findsOneWidget);
  });

  testWidgets('iron + water motor on: overload warning (demo step 2)', (
    tester,
  ) async {
    final appliances = FakeApplianceRepository(demoAppliances());
    await _pumpApp(
      tester,
      system: FakeSystemRepository(demoSystem()),
      appliances: appliances,
    );
    await appliances.setOn('iron', isOn: true);
    await appliances.setOn('motor', isOn: true);
    await tester.pumpAndSettle();
    expect(find.text('Overload'), findsOneWidget);
  });

  testWidgets('no household yet: welcome, then demo opens the dashboard', (
    tester,
  ) async {
    final system = FakeSystemRepository();
    final appliances = FakeApplianceRepository();
    await _pumpApp(tester, system: system, appliances: appliances);
    expect(find.text('Try the demo household'), findsOneWidget);

    // What OnboardingController does after signing in.
    await appliances.loadDemo();
    await system.loadDemo();
    await tester.pumpAndSettle();
    expect(find.text('3h 28m'), findsOneWidget);
  });
}
