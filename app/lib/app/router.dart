import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/coming_soon_screen.dart';
import '../features/backup/domain/system_repository.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/loads/presentation/screens/load_planner_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/solar/presentation/screens/solar_screen.dart';
import '../features/settings/presentation/screens/sign_in_screen.dart';
import 'l10n/app_localizations.dart';

abstract final class Routes {
  static const welcome = '/welcome';
  static const home = '/';
  static const loads = '/loads';
  static const solar = '/solar';
  static const battery = '/battery';
  static const assistant = '/assistant';
  static const settings = '/settings';

  /// `?mode=signIn` opens it on "Sign in" instead of "Create account".
  static const signIn = '/sign-in';
}

/// Five tabs in a stateful shell (each tab keeps its scroll position), plus
/// the welcome flow until the household is set up.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(householdSystemProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final system = ref.read(householdSystemProvider);
      // Still reading the local cache: stay put rather than flash welcome.
      if (!system.hasValue && !system.hasError) return null;
      final hasSystem = system.value != null;
      final atWelcome = state.matchedLocation == Routes.welcome;
      // A returning user signs in before any household exists on this
      // device, so sign-in must be reachable without one.
      final atSignIn = state.matchedLocation == Routes.signIn;
      if (!hasSystem && !atWelcome && !atSignIn) return Routes.welcome;
      if (hasSystem && atWelcome) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => SignInScreen(
          initialMode: state.uri.queryParameters['mode'] == 'signIn'
              ? SignInMode.signIn
              : SignInMode.create,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabShell(shell: shell),
        branches: [
          _branch(Routes.home, (_) => const DashboardScreen()),
          _branch(Routes.loads, (_) => const LoadPlannerScreen()),
          _branch(Routes.solar, (_) => const SolarScreen()),
          _branch(
            Routes.battery,
            (l10n) => ComingSoonScreen(
              title: l10n.tabBattery,
              icon: BbIcons.batteryWarning,
              description: l10n.comingBattery,
            ),
          ),
          _branch(
            Routes.assistant,
            (l10n) => ComingSoonScreen(
              title: l10n.tabAssistant,
              icon: BbIcons.assistant,
              description: l10n.comingAssistant,
            ),
          ),
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
