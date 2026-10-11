import 'package:backup_brain/features/assistant/data/assistant_prompt.dart';
import 'package:backup_brain/features/assistant/domain/assistant_repository.dart';
import 'package:backup_brain/features/assistant/domain/energy_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

Future<FakeAssistantRepository> _openAssistant(
  WidgetTester tester, {
  String? answer = 'Your backup lasts 3h 28m.',
}) async {
  final assistant = FakeAssistantRepository(answer: answer);
  await pumpApp(
    tester,
    auth: FakeAuthRepository(account: signedInAsAsad),
    system: FakeSystemRepository(demoSystem()),
    appliances: FakeApplianceRepository(demoAppliances()),
    extra: [assistantRepositoryProvider.overrideWithValue(assistant)],
  );
  await tester.tap(find.text('Assistant'));
  await tester.pumpAndSettle();
  return assistant;
}

void main() {
  testWidgets('a suggested question sends the engine snapshot, not a guess', (
    tester,
  ) async {
    final assistant = await _openAssistant(tester);
    await tester.tap(find.text('How long will my battery last?'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Your backup lasts'), findsOneWidget);
    final call = assistant.calls.single;
    expect(call.history.single.text, 'How long will my battery last?');
    final now = call.snapshot.facts['now']! as Map<String, Object?>;
    // The §12 demo numbers, formatted as the dashboard shows them.
    expect(now['backupTimeLeft'], '3h 28m');
    expect(now['houseLoad'], '420 W');
    expect(call.snapshot.facts['inverterLimit'], '2,000 W');
    final first = (call.snapshot.facts['switchOffOne']! as List).first as Map;
    expect(first['turnOff'], 'LED TV');
  });

  testWidgets('no AI: template answer from the same numbers, then retry', (
    tester,
  ) async {
    final assistant = await _openAssistant(tester, answer: null);
    await tester.enterText(find.byType(EditableText), 'Kitni der chalegi?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    expect(find.textContaining('No internet'), findsOneWidget);
    expect(find.textContaining('Backup lasts 3h 28m at 420 W'), findsOneWidget);

    assistant.answer = 'Back online: 3h 28m.';
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No internet'), findsNothing);
    expect(find.textContaining('Back online'), findsOneWidget);
    // The retry asks the same question once, not twice.
    expect(assistant.calls.last.history.length, 1);
  });

  testWidgets('battery danger gets the fixed safety text, never the AI', (
    tester,
  ) async {
    final assistant = await _openAssistant(tester);
    await tester.enterText(
      find.byType(EditableText),
      'meri battery phool gayi hai',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Disconnect the battery now'), findsOneWidget);
    expect(assistant.calls, isEmpty);
  });

  test('the prompt forbids new numbers and carries the snapshot', () {
    const snapshot = EnergySnapshot(
      facts: {
        'now': {'backupTimeLeft': '3h 28m'},
      },
      backupHours: 3.47,
      loadW: 420,
    );
    final prompt = buildSystemPrompt(snapshot, ReplyLanguage.romanUrdu);
    expect(prompt, contains('Never calculate'));
    expect(prompt, contains('"backupTimeLeft": "3h 28m"'));
    expect(prompt, contains('Roman Urdu'));
  });
}
