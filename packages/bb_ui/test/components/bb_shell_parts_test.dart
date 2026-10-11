import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

const _items = [
  BbNavItem(icon: BbIcons.home, activeIcon: BbIcons.homeActive, label: 'Home'),
  BbNavItem(
    icon: BbIcons.loads,
    activeIcon: BbIcons.loadsActive,
    label: 'Loads',
  ),
  BbNavItem(
    icon: BbIcons.solar,
    activeIcon: BbIcons.solarActive,
    label: 'Solar',
  ),
  BbNavItem(
    icon: BbIcons.battery,
    activeIcon: BbIcons.batteryActive,
    label: 'Battery',
  ),
  BbNavItem(
    icon: BbIcons.assistant,
    activeIcon: BbIcons.assistantActive,
    label: 'Assistant',
  ),
];

Widget _tile({bool value = true, ValueChanged<bool>? onChanged}) =>
    BbLoadToggleTile(
      icon: BbIcons.fan,
      name: 'Ceiling fan (bedroom)',
      watts: '75 W',
      priority: BbPriority.comfort,
      priorityLabel: 'Use carefully',
      value: value,
      onChanged: onChanged ?? (_) {},
    );

void main() {
  testWidgets('nav bar reports the tapped index and marks selection', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    int? tapped;
    await tester.pumpWidget(
      themed(
        BbNavBar(items: _items, selectedIndex: 0, onSelect: (i) => tapped = i),
      ),
    );
    await tester.tap(find.text('Solar'));
    expect(tapped, 2);
    expect(
      tester.getSemantics(find.text('Home')),
      matchesSemantics(
        label: 'Home',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('tapping anywhere on the load tile toggles it', (tester) async {
    bool? next;
    await tester.pumpWidget(themed(_tile(onChanged: (v) => next = v)));
    await tester.tap(find.text('Ceiling fan (bedroom)'));
    expect(next, isFalse);
  });

  testWidgets('load tile announces its toggled state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(themed(_tile(value: false)));
    expect(
      tester.getSemantics(find.text('Ceiling fan (bedroom)')),
      isSemantics(hasToggledState: true, isToggled: false),
    );
    handle.dispose();
  });

  testWidgets('avoid-on-backup badge carries a warning icon', (tester) async {
    await tester.pumpWidget(
      themed(
        const BbPriorityBadge(
          priority: BbPriority.avoidOnBackup,
          label: 'Avoid on backup',
        ),
      ),
    );
    expect(find.byIcon(BbIcons.warning), findsOneWidget);
  });

  goldenMatrix(
    'bb_nav_bar',
    () => BbNavBar(items: _items, selectedIndex: 1, onSelect: (_) {}),
    size: const Size(400, 120),
    scroll: false,
  );

  goldenMatrix(
    'bb_load_toggle_tile',
    () => BbCard.list(
      children: [
        _tile(),
        const BbLoadToggleTile(
          icon: BbIcons.iron,
          name: 'Iron',
          watts: '1000 W',
          priority: BbPriority.avoidOnBackup,
          priorityLabel: 'Avoid on backup',
          value: false,
          onChanged: null,
        ),
        BbLoadToggleTile(
          icon: BbIcons.router,
          name: 'Router',
          watts: '10 W',
          priority: BbPriority.essential,
          priorityLabel: 'Keep',
          value: true,
          onChanged: (_) {},
        ),
      ],
    ),
    size: const Size(400, 360),
  );
}
