import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_kaplan/shared/widgets/aurora_fab.dart';
import '../../../core/providers/theme_provider.dart';

class MainLayoutScreen extends ConsumerWidget {
  final Widget child;

  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    final String location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (location.startsWith('/leaderboard')) {
      currentIndex = 1;
    } else if (location.startsWith('/ai-tutor')) {
      currentIndex = 2;
    } else if (location.startsWith('/leagues')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: isDarkMode ? const Color(0xFF171B36) : colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.5),
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/leaderboard');
                break;
              case 2:
                context.go('/ai-tutor');
                break;
              case 3:
                context.go('/leagues');
                break;
              case 4:
                context.go('/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Aprender',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'Ranking',
            ),
            // Espacio vacío para el FAB central
            BottomNavigationBarItem(
              icon: SizedBox(height: 24),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: 'Ligas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Cuenta',
            ),
          ],
        ),
      ),
      floatingActionButton: AuroraFab(
        onTap: () => context.go('/ai-tutor'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
