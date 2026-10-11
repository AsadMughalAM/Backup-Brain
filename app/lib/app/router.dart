import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assistant/presentation/screens/assistant_screen.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/battery/presentation/screens/battery_help_screen.dart';
import '../features/battery/presentation/screens/battery_reading_screen.dart';
import '../features/battery/presentation/screens/battery_screen.dart';
import '../features/backup/domain/system_repository.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/estimator/presentation/screens/estimator_screen.dart';
import '../features/loads/presentation/screens/load_planner_screen.dart';
import '../features/outages/presentation/screens/add_schedule_time_screen.dart';
import '../features/outages/presentation/screens/outages_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/setup/domain/setup_draft_repository.dart';
import '../features/setup/presentation/controllers/setup_controller.dart';
import '../features/setup/presentation/screens/setup_screen.dart';
import '../features/solar/presentation/screens/solar_screen.dart';
import 'l10n/app_localizations.dart';
import 'session/household_setup.dart';

abstract final class Routes {
  static const signUp = '/sign-up';
  static const login = '/login';
  static const home = '/';
  static const loads = '/loads';
  static const solar = '/solar';
  static const battery = '/battery';
  static const assistant = '/assistant';
  static const settings = '/settings';
  static const outages = '/outages';
  static const estimator = '/estimator';
  static const batteryHelp = '/battery-help';
  static String batteryReading(String outageId) => '/battery/reading/$outageId';
  static const outagesAddTime = '/outages/add-time';
  static const setup = '/setup';
  static const editHome = '/settings/home';

  static const _auth = {signUp, login};

  /// Where a signed-out user may be: setup first, then an account.
  static const _signedOut = {setup, signUp, login};
}

/// Signed out → setup first (it is the useful part, so it comes before any
/// account), then sign-up / login; a finished setup opens on sign-up.
/// Signed in → the five tabs; signing in from any auth screen lands on Home
/// by itself. An account with no household and no finished setup on this
/// phone goes to setup, which ends on Home once the household is saved.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(isSignedInProvider, (_, _) => refresh.value++);
  ref.listen(householdSetupProvider, (_, _) => refresh.value++);
  ref.listen(
    householdSystemProvider.select((s) => s.value != null),
    (_, _) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(isSignedInProvider);
      // Firebase restores the session from disk first: wait, don't flash.
      if (signedIn == null) return null;
      final location = state.matchedLocation;
      if (!signedIn) {
        if (Routes._signedOut.contains(location)) return null;
        final draft = ref.read(setupDraftRepositoryProvider).load();
        return draft?.finished == true ? Routes.signUp : Routes.setup;
      }
      if (Routes._auth.contains(location)) return Routes.home;

      final hasHousehold = ref.read(householdSystemProvider).value != null;
      final atSetup = location == Routes.setup;
      if (hasHousehold && atSetup) return Routes.home;
      final needsSetup =
          !hasHousehold &&
          ref.read(householdSetupProvider) == HouseholdStatus.missing;
      if (needsSetup && !atSetup) return Routes.setup;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.setup,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: Routes.editHome,
        builder: (context, state) =>
            const SetupScreen(mode: SetupMode.editHome),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.outages,
        builder: (context, state) =>
            const OutagesScreen(addTimeLocation: Routes.outagesAddTime),
      ),
      GoRoute(
        path: '/battery/reading/:id',
        builder: (context, state) =>
            BatteryReadingScreen(outageId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.batteryHelp,
        builder: (context, state) => const BatteryHelpScreen(),
      ),
      GoRoute(
        path: Routes.estimator,
        builder: (context, state) => const EstimatorScreen(),
      ),
      GoRoute(
        path: Routes.outagesAddTime,
        builder: (context, state) => const AddScheduleTimeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabShell(shell: shell),
        branches: [
          _branch(Routes.home, (_) => const DashboardScreen()),
          _branch(Routes.loads, (_) => const LoadPlannerScreen()),
          _branch(
            Routes.solar,
            (_) => const SolarScreen(
              editHomeLocation: Routes.editHome,
              estimatorLocation: Routes.estimator,
            ),
          ),
          _branch(
            Routes.battery,
            (_) => const BatteryScreen(
              readingLocation: Routes.batteryReading,
              shopsLocation: Routes.batteryHelp,
            ),
          ),
          _branch(Routes.assistant, (_) => const AssistantScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(
  String path,
  Widget Function(AppLocalizations l10n) screen,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, state) => screen(AppLocalizations.of(context)),
    ),
  ],
);

class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: BbNavBar(
        selectedIndex: shell.currentIndex,
        // Re-tapping the current tab returns it to its first page.
        onSelect: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          BbNavItem(
            icon: BbIcons.home,
            activeIcon: BbIcons.homeActive,
            label: l10n.tabHome,
          ),
          BbNavItem(
            icon: BbIcons.loads,
            activeIcon: BbIcons.loadsActive,
            label: l10n.tabLoads,
          ),
          BbNavItem(
            icon: BbIcons.solar,
            activeIcon: BbIcons.solarActive,
            label: l10n.tabSolar,
          ),
          BbNavItem(
            icon: BbIcons.battery,
            activeIcon: BbIcons.batteryActive,
            label: l10n.tabBattery,
          ),
          BbNavItem(
            icon: BbIcons.assistant,
            activeIcon: BbIcons.assistantActive,
            label: l10n.tabAssistant,
          ),
        ],
      ),
    );
  }
}
