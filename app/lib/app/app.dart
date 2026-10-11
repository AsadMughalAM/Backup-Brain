import 'dart:ui' show PointerDeviceKind;

import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'locale/locale_controller.dart';
import 'router.dart';
import '../core/services/alert_scheduler.dart';
import 'session/household_setup.dart';
import 'session/outage_alerts.dart';
import 'theme_mode/theme_mode_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(localeProvider);
    // Lives for the whole session: gives each new account a household.
    ref.watch(householdSetupProvider);
    // Keeps the F8 outage alert in step with the prediction.
    ref.watch(outageAlertsProvider);
    // Tapping an alert opens the Outages screen.
    ref.listen(alertTapsProvider, (_, next) {
      if (next.hasValue) ref.read(routerProvider).push(Routes.outages);
    });
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: AppMotion.normal,
      // Web/desktop default to visible scrollbars and wheel-only scrolling;
      // the app should look and drag like the Android build everywhere.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
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
