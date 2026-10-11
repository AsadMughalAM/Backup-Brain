import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

void main() {
  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(BbButton(label: 'Calculate', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Calculate'));
    expect(taps, 1);
  });

  testWidgets('disabled: no callback, semantics say disabled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(const BbButton(label: 'Calculate', onPressed: null)),
    );
    await tester.tap(find.text('Calculate'));
    expect(
      tester.getSemantics(find.text('Calculate')),
      matchesSemantics(
        label: 'Calculate',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        isFocusable: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('loading: ignores taps, shows spinner and progressive label', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        BbButton(
          label: 'Find shops',
          loadingLabel: 'Finding shops…',
          loading: true,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.text('Finding shops…'), findsOneWidget);
    expect(find.byType(BbSpinner), findsOneWidget);
    await tester.tap(find.text('Finding shops…'));
    expect(taps, 0);
  });

  testWidgets('keyboard: Enter activates the focused button', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(BbButton(label: 'Light gayi', onPressed: () => taps++)),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 1);
  });

  testWidgets('small button still has a 48 dp touch target', (tester) async {
    await tester.pumpWidget(
      themed(
        Center(
          child: BbButton(
            label: 'Skip',
            size: BbButtonSize.sm,
            variant: BbButtonVariant.ghost,
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(BbButton)).height,
      greaterThanOrEqualTo(AppSizes.minTouchTarget),
    );
  });

  testWidgets('icon button: tooltip is the label, 48 × 48', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        Center(
          child: BbIconButton(
            icon: BbIcons.themeDark,
            tooltip: 'Switch theme',
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Switch theme'), findsOneWidget);
    expect(tester.getSize(find.byType(BbIconButton)), const Size(48, 48));
    handle.dispose();
  });

  goldenMatrix(
    'bb_button',
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbButton(
          label: 'What should I turn off?',
          icon: BbIcons.loads,
          onPressed: () {},
        ),
        const BbGap.md(),
        BbButton.secondary(label: 'My battery is kharab', onPressed: () {}),
        const BbGap.md(),
        BbButton.tonal(
          label: 'Add appliance',
          icon: BbIcons.add,
          onPressed: () {},
        ),
        const BbGap.md(),
        BbButton.ghost(label: 'See all', onPressed: () {}),
        const BbGap.md(),
        BbButton.danger(label: 'Delete appliance', onPressed: () {}),
        const BbGap.md(),
        const BbButton(label: 'Disabled', onPressed: null),
        const BbGap.md(),
        BbButton(
          label: 'Find shops',
          loading: true,
          loadingLabel: 'Finding shops…',
          onPressed: () {},
        ),
        const BbGap.md(),
        BbButton(
          label: 'Light gayi',
          size: BbButtonSize.lg,
          expand: true,
          onPressed: () {},
        ),
        const BbGap.md(),
        Row(
          children: [
            BbIconButton(
              icon: BbIcons.settings,
              tooltip: 'Settings',
              onPressed: () {},
            ),
            BbIconButton(
              icon: BbIcons.close,
              tooltip: 'Close',
              variant: BbIconButtonVariant.tonal,
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
    size: const Size(400, 760),
  );
}
