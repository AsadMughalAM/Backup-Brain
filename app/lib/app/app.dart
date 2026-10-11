import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'locale/locale_controller.dart';
import 'router.dart';
import 'theme_mode/theme_mode_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(localeProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: AppMotion.normal,
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Flutter treats every 'ur' locale as right-to-left, but Roman Urdu is
      // written left-to-right.
      builder: (context, child) => language == AppLanguage.romanUrdu
          ? Directionality(textDirection: TextDirection.ltr, child: child!)
          : child!,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
