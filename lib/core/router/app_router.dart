import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../../providers/preferences_provider.dart';
import 'go_router_refresh.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/coach/presentation/coach_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/dashboard_tab.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/insights/presentation/insights_page.dart';
import '../../features/onboarding/presentation/onboarding_flow.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/simulator/presentation/simulator_page.dart';
import '../../features/situation_library/presentation/situation_library_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/tone_analyzer/presentation/tone_analyzer_page.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  if (!AppConfig.isSupabaseConfigured) {
    return GoRouter(
      initialLocation: '/setup',
      routes: [
        GoRoute(
          path: '/setup',
          builder: (context, state) => const _SetupRequiredPage(),
        ),
      ],
    );
  }

  final authRefresh = GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  );
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final onboardingDone = ref.read(onboardingCompletedProvider);
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;
      if (loc == '/forgot-password' || loc == '/reset-password') return null;

      if (session == null && loc != '/login') {
        return '/login';
      }

      if (session != null && !onboardingDone && loc != '/onboarding') {
        return '/onboarding';
      }

      if (session != null && onboardingDone && loc == '/login') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/coach',
                builder: (context, state) => const CoachPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/simulator',
                builder: (context, state) => const SimulatorPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tone',
        builder: (context, state) => const ToneAnalyzerPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/library',
        builder: (context, state) => const SituationLibraryPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
    ],
  );
});

class _SetupRequiredPage extends StatelessWidget {
  const _SetupRequiredPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Supabase is not configured. Add SUPABASE_URL and '
          'SUPABASE_ANON_KEY via --dart-define or edit lib/core/config/app_config.dart '
          'for development.',
        ),
      ),
    );
  }
}
