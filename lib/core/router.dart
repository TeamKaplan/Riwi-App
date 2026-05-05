import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/learning/presentation/lesson_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/notifications_screen.dart';
import '../features/profile/presentation/sound_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/leagues/presentation/leagues_screen.dart';
import '../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../features/main_layout/presentation/main_layout_screen.dart';

// GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
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
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '1';
          return LessonScreen(lessonId: id);
        },
      ),
    ],
  );
});
