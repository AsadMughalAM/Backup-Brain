import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

void main() {
  testWidgets('every banner tone shows an icon (never color alone)', (
    tester,
  ) async {
    for (final tone in BbBannerTone.values) {
      await tester.pumpWidget(themed(BbBanner(tone: tone, message: 'm')));
      expect(find.byType(Icon), findsOneWidget, reason: tone.name);
    }
  });

  testWidgets('dismiss button calls onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      themed(
        BbBanner(
          message: 'Prices updated',
          onDismiss: () => dismissed = true,
          dismissLabel: 'Close',
        ),
      ),
    );
    await tester.tap(find.byType(BbIconButton));
    expect(dismissed, isTrue);
  });

  testWidgets('danger (safety) banners are never dismissible', (tester) async {
    await tester.pumpWidget(
      themed(
        BbBanner(
          tone: BbBannerTone.danger,
          message: 'Overload',
          onDismiss: () {},
          dismissLabel: 'Close',
        ),
      ),
    );
    expect(find.byType(BbIconButton), findsNothing);
  });

  testWidgets('spinner is static with reduced motion', (tester) async {
    await tester.pumpWidget(themed(const BbSpinner()));
    // Settles because no animation is running under disableAnimations.
    await tester.pumpAndSettle();
    expect(find.byType(BbSpinner), findsOneWidget);
  });

  goldenMatrix(
    'bb_banner',
    () => Column(
      children: [
        BbBanner(
          message: 'Prices last updated 3 Oct. Estimates only.',
          onDismiss: () {},
          dismissLabel: 'Close',
        ),
        const BbGap.md(),
        const BbBanner(
          tone: BbBannerTone.success,
          message: 'Battery will be full by 4:30 PM.',
        ),
        const BbGap.md(),
        const BbBanner(
          tone: BbBannerTone.warning,
          title: 'Deep discharge',
          message: 'Avoid discharging below 50%.',
        ),
        const BbGap.md(),
        const BbBanner(
          tone: BbBannerTone.danger,
          title: 'Overload',
          message: 'Load is above what your inverter can supply.',
        ),
      ],
    ),
    size: const Size(400, 520),
  );
}
