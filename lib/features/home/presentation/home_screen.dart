import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_kaplan/shared/widgets/level_node.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../learning/data/levels/english_levels.dart';
import '../../learning/data/levels/development_levels.dart';
import '../../learning/data/levels/soft_skills_levels.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCourse = 0;

  List<Map<String, dynamic>> _getCourses(bool isSpanish) {
    return [
      {
        'name': isSpanish ? 'Inglés' : 'English',
        'icon': Icons.translate,
        'color': const Color(0xFF4CAF50),
        'levels': EnglishLevels.getAllLevels().length,
      },
      {
        'name': isSpanish ? 'Desarrollo' : 'Development',
        'icon': Icons.code,
        'color': const Color(0xFF6B5BFC),
        'levels': DevelopmentLevels.getAllLevels().length,
      },
      {
        'name': 'Soft Skills',
        'icon': Icons.psychology,
        'color': const Color(0xFFFF7043),
        'levels': SoftSkillsLevels.getAllLevels().length,
      },
    ];
  }

  /// Construye una decoración atractiva para los huecos del camino
  Widget _buildThematicDecoration(BuildContext context, int courseIndex, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    
    IconData icon;
    String label = "";
    
    if (courseIndex == 1) { // Desarrollo
      icon = Icons.laptop_mac;
      label = "Code";
    } else if (courseIndex == 0) { // Inglés
      icon = Icons.menu_book_rounded;
      label = "Read";
    } else { // Soft Skills
      icon = Icons.lightbulb_outline;
      label = "Idea";
    }

    return Opacity(
      opacity: 0.2, // Aumentada ligeramente para mejor visibilidad
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: colorScheme.onSurface), // Más grande
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calcula el offset X de un nivel (Sinuosidad más larga y suave)
  double _getOffset(int index) {
    return math.sin(index * 1.0) * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final progress = ref.watch(progressProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final courses = _getCourses(isSpanish);
    final course = courses[_selectedCourse];
    final int totalLevels = course['levels'] as int;
    final Color courseColor = course['color'] as Color;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
        elevation: 0,
        title: Row(
          children: [
            Icon(course['icon'] as IconData, color: courseColor, size: 26),
            const SizedBox(width: 8),
            Text(
              course['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                const SizedBox(width: 2),
                Text(
                  '${progress.streak}',
                  style: TextStyle(
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                const SizedBox(width: 2),
                Text(
                  '${progress.totalXP} XP',
                  style: TextStyle(
                    color: Colors.amber.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo del tema actual
          Positioned.fill(
            child: Container(
              color: colorScheme.surface,
            ),
          ),
          
          // Fondo limpio con muy pocas hojas sutiles
          Positioned.fill(
            child: CustomPaint(
              painter: _GrassPainter(isDarkMode: isDarkMode),
            ),
          ),

          Column(
            children: [
              // Selector de cursos
              Container(
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: List.generate(courses.length, (index) {
                    final c = courses[index];
                    final isSelected = _selectedCourse == index;
                    final color = c['color'] as Color;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCourse = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: color, width: 2) : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(c['icon'] as IconData, color: isSelected ? color : colorScheme.onSurfaceVariant, size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  c['name'] as String,
                                  style: TextStyle(
                                    color: isSelected ? color : colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Mapa de niveles con decoraciones en los huecos
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  itemCount: totalLevels,
                  itemBuilder: (context, index) {
                    final levelNumber = index + 1;
                    final isCompleted = progress.isLevelCompleted(_selectedCourse, levelNumber);
                    final isUnlocked = progress.isLevelUnlocked(_selectedCourse, levelNumber);
                    final offset = _getOffset(index);
                    
                    // Mostramos una decoración cada 2 niveles en el lado opuesto
                    final bool showDecoration = index % 3 == 1;
                    
                    // Ajustamos el desplazamiento de la decoración para que rellene mejor el espacio
                    // Si el nodo está muy a la derecha (offset positivo), la decoración va a la izquierda
                    final decorationOffset = offset > 0 ? -0.6 : 0.6;

                    return SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          if (showDecoration)
                            Align(
                              alignment: Alignment(decorationOffset, 0),
                              child: _buildThematicDecoration(context, _selectedCourse, isDarkMode),
                            ),
                          LevelNode(
                            levelNumber: levelNumber,
                            isCompleted: isCompleted,
                            isUnlocked: isUnlocked,
                            offset: offset,
                            courseColor: courseColor,
                            icon: levelNumber % 5 == 0 ? Icons.inventory_2 : (course['icon'] as IconData),
                            isChest: levelNumber % 5 == 0,
                            progress: isUnlocked && !isCompleted ? 0.4 : 0.0,
                            onTap: isUnlocked
                                ? () => context.push('/lesson/$_selectedCourse/$levelNumber')
                                : () {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.lock, color: Colors.white, size: 18),
                                            const SizedBox(width: 10),
                                            Text(
                                              isSpanish
                                                  ? 'Completa el nivel anterior para desbloquear'
                                                  : 'Complete the previous level to unlock',
                                            ),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        backgroundColor: Colors.grey.shade800,
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/// Pinta pequeñas hojas muy sutiles en el fondo
class _GrassPainter extends CustomPainter {
  final bool isDarkMode;
  _GrassPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      paint.color = (isDarkMode ? const Color(0xFF2E7D32) : const Color(0xFF8BC34A))
          .withOpacity(0.05);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 5, height: 12), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GrassPainter oldDelegate) => false;
}
