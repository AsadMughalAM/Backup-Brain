import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

Widget _tiles() => const Column(
  children: [
    Row(
      children: [
        Expanded(
          child: BbStatTile(
            icon: BbIcons.batteryHigh,
            tone: BbTone.success,
            label: 'Battery',
            value: '62',
            unit: '%',
          ),
        ),
        BbGap.md(),
        Expanded(
          child: BbStatTile(
            icon: BbIcons.loads,
            tone: BbTone.load,
            label: 'Load',
            value: '420',
            unit: 'W',
          ),
        ),
      ],
    ),
    BbGap.md(),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BbStatTile(
            icon: BbIcons.solar,
            tone: BbTone.solar,
            label: 'Solar today',
            value: '3.8',
            unit: 'kWh',
            delta: '35% below normal',
          ),
        ),
        BbGap.md(),
        Expanded(
          child: BbStatTile(
            icon: BbIcons.money,
            label: 'Estimated cost',
            value: '1,85,000',
            unit: 'PKR',
          ),
        ),
      ],
    ),
  ],
);

void main() {
  testWidgets('card never draws a border', (tester) async {
    await tester.pumpWidget(themed(const BbCard(child: Text('x'))));
    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(BbCard),
        matching: find.byType(DecoratedBox),
      ),
    );
    for (final box in boxes) {
      final d = box.decoration;
      if (d is BoxDecoration) expect(d.border, isNull);
    }
  });

  testWidgets('dark cards have no shadow (lighter surface instead)', (
    tester,
  ) async {
    await tester.pumpWidget(themed(const BbCard(child: Text('x')), dark: true));
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(BbCard),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((box.decoration as BoxDecoration).boxShadow, isEmpty);
  });

  testWidgets('stat tiles: long PKR value fits a narrow column at 1.5×', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(themed(_tiles(), textScale: 1.5));
    expect(tester.takeException(), isNull);
    expect(find.text('1,85,000'), findsOneWidget);
  });

  testWidgets('metric shows value and unit', (tester) async {
    await tester.pumpWidget(themed(const BbMetric(value: '420', unit: 'W')));
    expect(find.text('420'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
  });

  goldenMatrix(
    'bb_card',
    () => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BbCard(child: Text('Standard card on the page background.')),
        BbGap.lg(),
        BbCard(
          variant: BbCardVariant.highlight,
          child: Text(
            'Tomorrow may be 35% below normal. Avoid heavy loads after 6 PM.',
          ),
        ),
        BbGap.lg(),
        BbCard(
          variant: BbCardVariant.hero,
          child: Text('Hero card — holds the countdown ring.'),
        ),
      ],
    ),
    size: const Size(400, 420),
  );

  goldenMatrix('bb_stat_tile', _tiles, size: const Size(400, 420));

  goldenMatrix(
    'bb_metric',
    () => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbMetric(value: '3h 28m', unit: 'left', size: BbMetricSize.hero),
        BbMetric(value: '420', unit: 'W'),
        BbMetric(
          value: '4.2',
          unit: 'kWh',
          size: BbMetricSize.medium,
          tone: BbTone.solar,
        ),
        BbMetric(
          value: '+2h 10m',
          size: BbMetricSize.small,
          tone: BbTone.success,
        ),
      ],
    ),
    size: const Size(400, 320),
  );
}
