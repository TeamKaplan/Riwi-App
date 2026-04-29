import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_kaplan/shared/widgets/aurora_fab.dart';

class MainLayoutScreen extends StatelessWidget {
  final Widget child;

  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF23294C), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF171B36),
          selectedItemColor: const Color(0xFF6B5BFC),
          unselectedItemColor: Colors.grey.shade700,
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Aprender',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'Ranking',
            ),
            // Espacio vacío para el FAB central
            BottomNavigationBarItem(
              icon: const SizedBox(height: 24),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: 'Ligas',
            ),
            const BottomNavigationBarItem(
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
