import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

// A hazy day: the forecast runs well under the clear-day bars.
const _bars = [
  BbSolarBar(value: 20, potential: 60, label: '6'),
  BbSolarBar(value: 100, potential: 370),
  BbSolarBar(value: 110, potential: 650),
  BbSolarBar(value: 290, potential: 880, label: '9'),
  BbSolarBar(value: 470, potential: 1020),
  BbSolarBar(value: 460, potential: 1090),
  BbSolarBar(value: 700, potential: 1070, label: '12'),
  BbSolarBar(value: 690, potential: 970),
  BbSolarBar(value: 540, potential: 790),
  BbSolarBar(value: 370, potential: 540, label: '3'),
  BbSolarBar(value: 160, potential: 250),
  BbSolarBar(value: 15, potential: 0),
];

Widget _strip() => const BbCard(
  child: BbSolarForecastStrip(
    bars: _bars,
    forecastLabel: 'Forecast',
    potentialLabel: 'Clear day',
    semanticLabel: 'About 3.9 kWh of sun today',
  ),
);

void main() {
  testWidgets('chip: selected shows a check icon and selected semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(BbChip(label: 'Today', selected: true, onSelected: () {})),
    );
    expect(find.byIcon(BbIcons.check), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(BbChip)),
      isSemantics(
        label: 'Today',
        isSelected: true,
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasSelectedState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('chip: unselected has no icon; tap calls onSelected', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        BbChip(label: 'Tomorrow', selected: false, onSelected: () => taps++),
      ),
    );
    expect(find.byIcon(BbIcons.check), findsNothing);
    await tester.tap(find.byType(BbChip));
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(BbChip)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('strip: one sentence for screen readers, legend for both bars', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(themed(_strip()));
    expect(find.bySemanticsLabel('About 3.9 kWh of sun today'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('Clear day'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('strip: no potential → no clear-day legend; all-zero is safe', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const BbSolarForecastStrip(
          bars: [BbSolarBar(value: 0), BbSolarBar(value: 0)],
          forecastLabel: 'Forecast',
          potentialLabel: 'Clear day',
          semanticLabel: 'No sun',
        ),
      ),
    );
    expect(find.text('Clear day'), findsNothing);
  });

  goldenMatrix(
    'bb_chip',
    () => Wrap(
      spacing: AppSpacing.sm,
      children: [
        BbChip(label: 'Today', selected: true, onSelected: () {}),
        BbChip(label: 'Tomorrow', selected: false, onSelected: () {}),
        const BbChip(label: 'Disabled', selected: false, onSelected: null),
      ],
    ),
    size: const Size(400, 160),
  );

  goldenMatrix('bb_solar_forecast_strip', _strip, size: const Size(400, 320));

  goldenMatrix(
    'bb_empty_state',
    () => BbEmptyState(
      icon: BbIcons.offline,
      title: 'Needs internet once',
      message:
          'Connect once to get the sun forecast. After that it works offline.',
      action: BbButton.secondary(label: 'Try again', onPressed: () {}),
    ),
    size: const Size(400, 420),
  );
}
