import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

BbCountdownRing _ring({double soc = 0.62, bool overloaded = false}) =>
    BbCountdownRing(
      soc: soc,
      timeLabel: '3h 28m',
      caption: 'left at 420 W',
      footnote: 'Stops protecting battery at 15%',
      isOverloaded: overloaded,
    );

void main() {
  testWidgets('shows time and caption, one screen-reader sentence', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(themed(Center(child: _ring())));
    expect(find.text('3h 28m'), findsOneWidget);
    expect(find.text('left at 420 W'), findsOneWidget);
    expect(find.bySemanticsLabel('3h 28m, left at 420 W'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('240 px on phones, 200 px under 360 px wide', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    double ringWidth() => tester
        .getSize(
          find
              .descendant(
                of: find.byType(BbCountdownRing),
                matching: find.byType(CustomPaint),
              )
              .first,
        )
        .width;

    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpWidget(themed(Center(child: _ring())));
    expect(ringWidth(), 240);

    tester.view.physicalSize = const Size(340, 800);
    await tester.pumpWidget(themed(Center(child: _ring())));
    expect(ringWidth(), 200);
  });

  testWidgets('turning overload on pulses without errors', (tester) async {
    await tester.pumpWidget(themed(Center(child: _ring())));
    await tester.pumpWidget(themed(Center(child: _ring(overloaded: true))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no overflow at text scale 1.5 on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      themed(Center(child: _ring(soc: 0.12)), textScale: 1.5),
    );
    expect(tester.takeException(), isNull);
  });

  goldenMatrix(
    'bb_countdown_ring',
    () => Column(
      children: [
        BbCard(
          variant: BbCardVariant.hero,
          child: Center(child: _ring()),
        ),
        const BbGap.lg(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // FittedBox shrinks layout too (Transform.scale would not).
            SizedBox(width: 150, child: FittedBox(child: _ring(soc: 0.35))),
            SizedBox(width: 150, child: FittedBox(child: _ring(soc: 0.12))),
          ],
        ),
      ],
    ),
    size: const Size(400, 720),
  );
}
