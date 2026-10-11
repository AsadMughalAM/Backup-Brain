import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

Widget _screen() => BbScaffold(
  title: 'Load planner',
  actions: [
    BbIconButton(icon: BbIcons.settings, tooltip: 'Settings', onPressed: () {}),
  ],
  banner: const BbBanner(
    tone: BbBannerTone.warning,
    message: "You're offline — showing saved data",
  ),
  body: ListView(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    children: const [
      BbCard(child: Text('Turn off first')),
      BbGap.lg(),
      BbCard(child: Text('Appliances')),
    ],
  ),
  bottomAction: BbButton(
    label: 'Apply',
    size: BbButtonSize.lg,
    expand: true,
    onPressed: () {},
  ),
);

void main() {
  testWidgets('renders title, banner, body and sticky action', (tester) async {
    await tester.pumpWidget(themed(_screen(), scroll: false));
    expect(find.text('Load planner'), findsOneWidget);
    expect(find.byType(BbBanner), findsOneWidget);
    expect(find.text('Turn off first'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('body gets the compact side margin', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(themed(_screen(), scroll: false));
    final card = tester.getTopLeft(find.text('Turn off first'));
    // Side margin 16 + card padding 16.
    expect(card.dx, AppSpacing.lg * 2);
  });

  goldenMatrix(
    'bb_scaffold',
    _screen,
    scroll: false,
    size: const Size(400, 640),
  );
}
