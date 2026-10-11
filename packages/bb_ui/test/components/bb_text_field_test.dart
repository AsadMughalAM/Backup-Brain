import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

Widget _password({String? error}) => BbTextField(
  label: 'Password',
  obscure: true,
  showPasswordLabel: 'Show password',
  hidePasswordLabel: 'Hide password',
  errorText: error,
);

void main() {
  testWidgets('password is hidden until the toggle is pressed', (tester) async {
    final controller = TextEditingController(text: 'secret1');
    await tester.pumpWidget(
      themed(
        BbTextField(
          label: 'Password',
          controller: controller,
          obscure: true,
          showPasswordLabel: 'Show password',
          hidePasswordLabel: 'Hide password',
        ),
      ),
    );
    TextField field() => tester.widget<TextField>(find.byType(TextField));
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('error shows text and a warning icon, not color alone', (
    tester,
  ) async {
    await tester.pumpWidget(themed(_password(error: 'Too short')));
    expect(find.text('Too short'), findsOneWidget);
    expect(find.byIcon(BbIcons.warning), findsOneWidget);
  });

  testWidgets('typing reaches the controller', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      themed(BbTextField(label: 'Email', controller: controller)),
    );
    await tester.enterText(find.byType(TextField), 'a@b.pk');
    expect(controller.text, 'a@b.pk');
  });

  goldenMatrix(
    'bb_text_field',
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BbTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: TextEditingController(),
        ),
        const BbGap.lg(),
        BbTextField(
          label: 'Email',
          helper: 'We only use this to sign you in.',
          controller: TextEditingController(text: 'asad@example.pk'),
        ),
        const BbGap.lg(),
        _password(error: 'Use at least 6 characters.'),
      ],
    ),
    size: const Size(400, 420),
  );
}
