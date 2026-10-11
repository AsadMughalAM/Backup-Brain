import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

Widget _steps(int current) => BbStepIndicator(
  labels: const ['Home', 'Battery', 'Appliances'],
  current: current,
  semanticLabel: 'Step ${current + 1} of 3',
);

void main() {
  testWidgets('steps: done steps show a check, others their number', (
    tester,
  ) async {
    await tester.pumpWidget(themed(_steps(1)));
    expect(find.byIcon(BbIcons.check), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('steps: one sentence for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(themed(_steps(1)));
    expect(find.bySemanticsLabel('Step 2 of 3'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('choice card: selected shows a filled check; tap selects', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(
        Column(
          children: [
            BbChoiceCard(
              icon: BbIcons.solarPanel,
              title: 'Yes, I have solar',
              selected: true,
              onSelected: () {},
            ),
            BbChoiceCard(
              icon: BbIcons.battery,
              title: 'No solar',
              selected: false,
              onSelected: () => taps++,
            ),
          ],
        ),
      ),
    );
    expect(find.byIcon(BbIcons.radioOn), findsOneWidget);
    expect(find.byIcon(BbIcons.radioOff), findsOneWidget);
    await tester.tap(find.text('No solar'));
    expect(taps, 1);
  });

  testWidgets('choice card: selected state reaches screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        BbChoiceCard(
          icon: BbIcons.solarPanel,
          title: 'Yes, I have solar',
          selected: true,
          onSelected: () {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(BbChoiceCard)),
      isSemantics(label: 'Yes, I have solar', isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('stepper: + and − change the value within its limits', (
    tester,
  ) async {
    var value = 1;
    await tester.pumpWidget(
      themed(
        StatefulBuilder(
          builder: (context, setState) => BbQuantityStepper(
            value: value,
            min: 1,
            max: 2,
            label: 'Ceiling fan',
            decreaseLabel: 'Fewer',
            increaseLabel: 'More',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('More'));
    await tester.pump();
    expect(value, 2);
    // At the max: + does nothing.
    await tester.tap(find.byTooltip('More'));
    await tester.pump();
    expect(value, 2);
    await tester.tap(find.byTooltip('Fewer'));
    await tester.pump();
    expect(value, 1);
  });

  testWidgets('stepper: screen readers can adjust it directly', (tester) async {
    final handle = tester.ensureSemantics();
    var value = 2;
    await tester.pumpWidget(
      themed(
        BbQuantityStepper(
          value: value,
          label: 'Ceiling fan',
          decreaseLabel: 'Fewer',
          increaseLabel: 'More',
          onChanged: (v) => value = v,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Ceiling fan')).value,
      '2',
    );
    tester.semantics.increase(find.semantics.byLabel('Ceiling fan'));
    expect(value, 3);
    handle.dispose();
  });

  goldenMatrix(
    'bb_step_indicator',
    () => Column(
      children: [
        _steps(0),
        const BbGap.xl(),
        _steps(1),
        const BbGap.xl(),
        _steps(2),
      ],
    ),
    size: const Size(400, 300),
  );

  goldenMatrix(
    'bb_choice_card',
    () => Column(
      children: [
        BbChoiceCard(
          icon: BbIcons.solarPanel,
          title: 'Yes, I have solar',
          subtitle: 'Panels on the roof',
          selected: true,
          onSelected: () {},
        ),
        const BbGap.md(),
        BbChoiceCard(
          icon: BbIcons.battery,
          title: 'No, just UPS and battery',
          subtitle: 'Backup time, and what solar would cost',
          selected: false,
          onSelected: () {},
        ),
      ],
    ),
    size: const Size(400, 320),
  );

  goldenMatrix(
    'bb_quantity_stepper',
    () => Column(
      children: [
        BbQuantityStepper(
          value: 0,
          label: 'Iron',
          decreaseLabel: 'Fewer',
          increaseLabel: 'More',
          onChanged: (_) {},
        ),
        BbQuantityStepper(
          value: 2,
          label: 'Ceiling fan',
          decreaseLabel: 'Fewer',
          increaseLabel: 'More',
          onChanged: (_) {},
        ),
      ],
    ),
    size: const Size(400, 200),
  );
}
