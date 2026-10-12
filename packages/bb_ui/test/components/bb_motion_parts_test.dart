import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden.dart';

double _opacityOf(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(BbAppear),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

void main() {
  testWidgets('BbAppear rises in once, and is simply there with reduced '
      'motion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BbAppear(index: 2, child: Text('Hello'))),
    );
    expect(_opacityOf(tester), 0);
    await tester.pumpAndSettle();
    expect(_opacityOf(tester), 1);

    // themed() turns animations off, like the OS reduce-motion setting.
    await tester.pumpWidget(
      themed(const BbAppear(index: 5, child: Text('Hello'))),
    );
    await tester.pump();
    expect(_opacityOf(tester), 1);
  });

  testWidgets('BbBackupGauge speaks the whole answer, not the arc', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        const BbBackupGauge(
          soc: 0.6,
          semanticLabel: '3h 28m of backup at 420 W, battery 60%',
          child: Text('3h 28m'),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('3h 28m of backup at 420 W, battery 60%'),
      findsOneWidget,
    );
    handle.dispose();
  });

  goldenMatrix(
    'bb_backup_gauge',
    () => const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BbBackupGauge(
            soc: 0.6,
            semanticLabel: 'Battery 60%',
            child: BbMetric(value: '3h 28m', size: BbMetricSize.hero),
          ),
          BbGap.lg(),
          BbBackupGauge(
            soc: 0.15,
            semanticLabel: 'Battery 15%',
            child: BbMetric(value: '25m', size: BbMetricSize.hero),
          ),
        ],
      ),
    ),
    size: const Size(400, 460),
  );
}
