import 'package:bb_ui/bb_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/coming_soon_screen.dart';
import '../features/assistant/presentation/screens/assistant_screen.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/screens/intro_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/loads/presentation/screens/load_planner_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/solar/presentation/screens/solar_screen.dart';
import 'l10n/app_localizations.dart';

abstract final class Routes {
  static const intro = '/intro';
  static const signUp = '/sign-up';
  static const login = '/login';
  static const home = '/';
  static const loads = '/loads';
  static const solar = '/solar';
  static const battery = '/battery';
  static const assistant = '/assistant';
  static const settings = '/settings';

  static const _signedOut = {intro, signUp, login};
}

/// Signed out → intro / sign-up / login only. Signed in → the five tabs;
/// signing in from any auth screen lands on Home by itself.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(isSignedInProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(isSignedInProvider);
      // Firebase restores the session from disk first: wait, don't flash.
      if (signedIn == null) return null;
      final atAuth = Routes._signedOut.contains(state.matchedLocation);
      if (!signedIn && !atAuth) return Routes.intro;
      if (signedIn && atAuth) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
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
