import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

void main() {
  testWidgets('tapping logs, and screen readers hear state plus action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      themed(
        BbGridStatusPill(
          gridOn: false,
          label: 'Light gayi',
          duration: '1h 12m',
          actionLabel: 'Light aa gayi?',
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.byType(BbGridStatusPill));
    expect(taps, 1);
    expect(
      find.bySemanticsLabel('Light gayi, 1h 12m, Light aa gayi?'),
      findsOneWidget,
    );
    expect(find.byIcon(BbIcons.gridOff), findsOneWidget);
    expect(
      tester.getSize(find.byType(BbGridStatusPill)).height,
      greaterThanOrEqualTo(AppSizes.minTouchTarget),
    );
    handle.dispose();
  });

  goldenMatrix(
    'bb_grid_status_pill',
    () => Column(
      children: [
        BbGridStatusPill(
          gridOn: true,
          label: 'Light hai',
          actionLabel: 'Light gayi?',
          onTap: () {},
        ),
        const BbGap.md(),
        BbGridStatusPill(
          gridOn: false,
          label: 'Light gayi',
          duration: '1h 12m',
          actionLabel: 'Light aa gayi?',
          onTap: () {},
        ),
      ],
    ),
    size: const Size(400, 200),
  );
}
