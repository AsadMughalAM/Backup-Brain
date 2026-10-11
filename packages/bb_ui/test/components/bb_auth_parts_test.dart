import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

void main() {
  testWidgets('Google button taps and is a 48 dp+ button', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        BbGoogleButton(label: 'Continue with Google', onPressed: () => taps++),
      ),
    );
    await tester.tap(find.text('Continue with Google'));
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(BbGoogleButton)).height,
      greaterThanOrEqualTo(AppSizes.minTouchTarget),
    );
  });

  testWidgets('Google button ignores taps while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        BbGoogleButton(
          label: 'Continue with Google',
          loading: true,
          onPressed: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('Continue with Google'));
    expect(taps, 0);
    expect(find.byType(BbSpinner), findsOneWidget);
  });

  testWidgets('pill field: label is the placeholder and the field name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        const BbTextField(
          label: 'Enter your email',
          pill: true,
          prefixIcon: BbIcons.email,
        ),
      ),
    );
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Enter your email')), findsWidgets);
    expect(find.byIcon(BbIcons.email), findsOneWidget);
    handle.dispose();
  });

  goldenMatrix(
    'bb_auth_parts',
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BbTextField(
          label: 'Enter your email',
          pill: true,
          prefixIcon: BbIcons.email,
        ),
        const BbGap.md(),
        const BbTextField(
          label: 'Enter your password',
          pill: true,
          prefixIcon: BbIcons.lock,
          obscure: true,
          showPasswordLabel: 'Show password',
          hidePasswordLabel: 'Hide password',
          errorText: 'Use at least 6 characters.',
        ),
        const BbGap.lg(),
        BbButton(
          label: 'Sign up',
          size: BbButtonSize.lg,
          expand: true,
          onPressed: () {},
        ),
        const BbGap.lg(),
        BbGoogleButton(label: 'Continue with Google', onPressed: () {}),
      ],
    ),
    size: const Size(400, 320),
  );
}
