import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in the real theme, the given text scale and reduced motion
/// (so tweens land immediately and spinners stand still).
Widget themed(
  Widget child, {
  bool dark = false,
  double textScale = 1.0,
  bool scroll = true,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: true,
    ),
    child: app!,
  ),
  home: Scaffold(
    body: scroll
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          )
        : child,
  ),
);

/// Registers the golden matrix from TECH_STACK.md §6.7: light + dark at text
/// scale 1.0 and 1.5. Update with `flutter test --update-goldens` — only on
/// purpose. Goldens are rendered on Windows; other OSes anti-alias slightly
/// differently, so regenerate them if CI runs elsewhere.
void goldenMatrix(
  String name,
  Widget Function() build, {
  Size size = const Size(400, 600),
  bool scroll = true,
}) {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.5]) {
      final variant = '${dark ? 'dark' : 'light'}_${scale}x';
      testWidgets('$name golden ($variant)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          themed(build(), dark: dark, textScale: scale, scroll: scroll),
        );
        await tester.pump();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$name.$variant.png'),
        );
      });
    }
  }
}
