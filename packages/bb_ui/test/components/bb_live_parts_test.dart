import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

Widget _editableTile({
  required VoidCallback onEdit,
  required ValueChanged<bool> onChanged,
  bool value = true,
}) => BbLoadToggleTile(
  icon: BbIcons.fan,
  name: 'Ceiling fan × 2',
  watts: '150 W',
  priority: BbPriority.comfort,
  priorityLabel: 'Use carefully',
  value: value,
  onChanged: onChanged,
  onEditWatts: onEdit,
  editWattsLabel: 'Change watts: Ceiling fan, 150 W',
);

void main() {
  group('BbBottomSheet', () {
    testWidgets('names itself for screen readers and shows its content', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        themed(
          const BbBottomSheet(
            title: 'What does your UPS show?',
            child: Text('Pick one'),
          ),
          scroll: false,
        ),
      );
      expect(find.text('Pick one'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('What does your UPS show?')),
        matchesSemantics(label: 'What does your UPS show?', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('long content scrolls inside the sheet', (tester) async {
      tester.view.physicalSize = const Size(400, 300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        themed(
          Align(
            alignment: Alignment.bottomCenter,
            child: BbBottomSheet(
              title: 'Which fan?',
              child: Column(
                children: [for (var i = 0; i < 30; i++) Text('Row $i')],
              ),
            ),
          ),
          scroll: false,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Which fan?'), findsOneWidget);
    });
  });

  group('BbChip with an icon', () {
    testWidgets('shows the icon until selected, then the check', (
      tester,
    ) async {
      await tester.pumpWidget(
        themed(
          const Wrap(
            children: [
              BbChip(
                label: '75%',
                icon: BbIcons.batteryHigh,
                selected: false,
                onSelected: null,
              ),
              BbChip(
                label: '50%',
                icon: BbIcons.batteryMedium,
                selected: true,
                onSelected: null,
              ),
            ],
          ),
        ),
      );
      expect(find.byIcon(BbIcons.batteryHigh), findsOneWidget);
      expect(find.byIcon(BbIcons.batteryMedium), findsNothing);
      expect(find.byIcon(BbIcons.check), findsOneWidget);
    });
  });

  group('BbLoadToggleTile with editable watts', () {
    testWidgets('the watts edit; the name and the switch toggle', (
      tester,
    ) async {
      var edits = 0;
      final toggles = <bool>[];
      await tester.pumpWidget(
        themed(_editableTile(onEdit: () => edits++, onChanged: toggles.add)),
      );
      await tester.tap(find.text('150 W'));
      expect(edits, 1);
      expect(toggles, isEmpty);
      await tester.tap(find.text('Ceiling fan × 2'));
      await tester.tap(find.byType(BbSwitch));
      expect(toggles, [false, false]);
      expect(edits, 1);
    });

    testWidgets('screen readers get the toggle and a labelled edit button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        themed(_editableTile(onEdit: () {}, onChanged: (_) {})),
      );
      expect(
        find.bySemanticsLabel('Change watts: Ceiling fan, 150 W'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.text('150 W')).height,
        lessThan(AppSizes.minTouchTarget),
      );
      final button = find.ancestor(
        of: find.text('150 W'),
        matching: find.byType(GestureDetector),
      );
      expect(
        tester.getSize(button.first).height,
        greaterThanOrEqualTo(AppSizes.minTouchTarget),
      );
      handle.dispose();
    });
  });

  group('BbStatTile with a tap', () {
    testWidgets('tapping runs the action; screen readers hear what it does', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        themed(
          BbStatTile(
            icon: BbIcons.batteryHigh,
            label: 'Battery',
            value: '55',
            unit: '%',
            delta: 'Estimate · tap to check',
            onTap: () => taps++,
            tapLabel: 'Check battery %',
          ),
        ),
      );
      await tester.tap(find.text('Battery'));
      expect(taps, 1);
      final node = tester.getSemantics(find.byType(BbStatTile));
      expect(node.hint, 'Check battery %');
      expect(node.label, contains('Estimate · tap to check'));
      handle.dispose();
    });
  });

  goldenMatrix(
    'bb_bottom_sheet',
    () => Align(
      alignment: Alignment.bottomCenter,
      child: BbBottomSheet(
        title: 'What does your UPS show?',
        child: Wrap(
          spacing: AppSpacing.sm,
          children: [
            BbChip(
              label: '100%',
              icon: BbIcons.batteryFull,
              selected: false,
              onSelected: () {},
            ),
            BbChip(
              label: '75%',
              icon: BbIcons.batteryHigh,
              selected: true,
              onSelected: () {},
            ),
            BbChip(
              label: '50%',
              icon: BbIcons.batteryMedium,
              selected: false,
              onSelected: () {},
            ),
            BbChip(
              label: '25%',
              icon: BbIcons.batteryLow,
              selected: false,
              onSelected: () {},
            ),
          ],
        ),
      ),
    ),
    size: const Size(400, 320),
    scroll: false,
  );

  goldenMatrix(
    'bb_load_toggle_tile_editable',
    () => BbCard.list(
      children: [
        _editableTile(onEdit: () {}, onChanged: (_) {}),
        _editableTile(onEdit: () {}, onChanged: (_) {}, value: false),
      ],
    ),
    size: const Size(400, 260),
  );
}
