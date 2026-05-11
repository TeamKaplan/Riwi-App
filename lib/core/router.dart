import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/learning/presentation/lesson_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/notifications_screen.dart';
import '../features/profile/presentation/sound_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/leagues/presentation/leagues_screen.dart';
import '../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../features/main_layout/presentation/main_layout_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Rutas públicas
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Rutas protegidas con shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainLayoutScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: '/ai-tutor',
            builder: (context, state) => const AiTutorScreen(),
          ),
          GoRoute(
            path: '/leagues',
            builder: (context, state) => const LeaguesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/sounds',
            builder: (context, state) => const SoundScreen(),
          ),
        ],
      ),

      // Lección (fuera del shell, sin bottom nav)
      GoRoute(
        path: '/lesson/:courseIndex/:levelId',
        builder: (context, state) {
          final courseIndex =
              int.tryParse(state.pathParameters['courseIndex'] ?? '0') ?? 0;
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '1') ?? 1;
          return LessonScreen(courseIndex: courseIndex, levelId: levelId);
        },
      ),
    ],
  );
});
