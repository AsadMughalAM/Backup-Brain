import 'dart:ui' show PointerDeviceKind;

import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/backup/domain/system_repository.dart';
import '../features/outages/presentation/controllers/reminder_controller.dart';
import '../features/solar/presentation/controllers/forecast_refresh_controller.dart';
import 'l10n/app_localizations.dart';
import 'locale/locale_controller.dart';
import 'router.dart';
import '../core/services/alert_scheduler.dart';
import 'session/household_setup.dart';
import 'session/outage_alerts.dart';
import 'theme_mode/theme_mode_controller.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Home and the assistant use the forecast too, so keep it fresh from
    // the app, not only the Solar tab: on start, on return, and once the
    // household's location is known. Skipped while the saved one is fresh.
    _lifecycle = AppLifecycleListener(onResume: _refreshForecast);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshForecast());
  }

  void _refreshForecast() =>
      ref.read(forecastRefreshProvider.notifier).refresh();

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider);
    // Lives for the whole session: gives each new account a household.
    ref.watch(householdSetupProvider);
    // Lives for the whole session: the 30-minute outage alert, and the
    // "Power gone?" reminders and countdown notice, follow the app's state.
    ref.watch(outageAlertsProvider);
    ref.watch(outageNotificationsProvider);
    // Tapping an alert opens the Outages screen.
    ref.listen(alertTapsProvider, (_, next) {
      if (next.hasValue) ref.read(routerProvider).push(Routes.outages);
    });
    ref.listen(householdSystemProvider.select((s) => s.value?.location?.site), (
      before,
      site,
    ) {
      if (site != null && before == null) _refreshForecast();
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
