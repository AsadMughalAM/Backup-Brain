import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/l10n/app_localizations.dart';
import '../../../../app/router.dart';
import '../widgets/auth_layout.dart';

/// First launch: three short slides (illustration on the sky, text card
/// below), then the round arrow leads to Sign up.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pages = PageController();
  var _page = 0;

  static const _icons = [
    BbIcons.batteryActive,
    BbIcons.loadsActive,
    BbIcons.solarActive,
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _icons.length - 1) {
      context.go(Routes.signUp);
      return;
    }
    _pages.nextPage(
      duration: AppMotion.of(context, AppMotion.normal),
      curve: AppMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final slides = [
      (l10n.intro1Title, l10n.intro1Body),
      (l10n.intro2Title, l10n.intro2Body),
      (l10n.intro3Title, l10n.intro3Body),
    ];
    final (title, body) = slides[_page];

    return Scaffold(
      backgroundColor: c.background,
      body: AuthBackground(
        // The sky reaches down to the card, as in the reference.
        skyEnd: 0.72,
        child: SafeArea(
          child: BbPagePadding(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _icons.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => _Illustration(icon: _icons[i]),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppElevation.level2.shadows(
                      Theme.of(context).brightness,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BbPageDots(
                        count: _icons.length,
                        current: _page,
                        semanticLabel: l10n.introPageOf(
                          _page + 1,
                          _icons.length,
                        ),
                      ),
                      const BbGap.xl(),
                      AnimatedSwitcher(
                        duration: AppMotion.of(context, AppMotion.normal),
                        child: Column(
                          key: ValueKey(_page),
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: c.secondary,
                              ),
                            ),
                            const BbGap.md(),
                            Text(
                              body,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const BbGap.xl(),
                      BbIconButton(
                        icon: BbIcons.forward,
                        tooltip: l10n.introNext,
                        variant: BbIconButtonVariant.hero,
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A big glyph on a soft disc, like the reference's weather art.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: ExcludeSemantics(
        child: Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface),
          child: Icon(icon, size: 96, color: c.secondary),
        ),
      ),
    );
  }
}
