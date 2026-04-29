import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_kaplan/shared/widgets/level_node.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCourse = 0;

  static const List<Map<String, dynamic>> _courses = [
    {
      'name': 'Inglés',
      'icon': Icons.translate,
      'color': Color(0xFF4CAF50),
      'levels': 20,
      'currentLevel': 5,
    },
    {
      'name': 'Desarrollo',
      'icon': Icons.code,
      'color': Color(0xFF6B5BFC),
      'levels': 15,
      'currentLevel': 3,
    },
    {
      'name': 'Soft Skills',
      'icon': Icons.psychology,
      'color': Color(0xFFFF7043),
      'levels': 12,
      'currentLevel': 2,
    },
  ];

  // Calcula el offset X de un nivel
  double _getOffset(int index) {
    final cycle = index % 4;
    if (cycle == 1) return 0.4;
    if (cycle == 3) return -0.4;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final course = _courses[_selectedCourse];
    final int totalLevels = course['levels'] as int;
    final int currentLevel = course['currentLevel'] as int;
    final Color courseColor = course['color'] as Color;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(course['icon'] as IconData, color: courseColor, size: 26),
            const SizedBox(width: 8),
            Text(
              course['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 26),
                const SizedBox(width: 2),
                Text('12', style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 26),
                const SizedBox(width: 2),
                Text('1200', style: TextStyle(color: Colors.amber.shade400, fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D1025),
              const Color(0xFF171B36),
              HSLColor.fromColor(courseColor).withLightness(0.08).withSaturation(0.6).toColor(),
              const Color(0xFF171B36),
              const Color(0xFF0D1025),
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Selector de cursos
            Container(
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F42),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A3060), width: 1),
              ),
              child: Row(
                children: List.generate(_courses.length, (index) {
                  final c = _courses[index];
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
                            Icon(c['icon'] as IconData, color: isSelected ? color : Colors.grey.shade600, size: 18),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                c['name'] as String,
                                style: TextStyle(
                                  color: isSelected ? color : Colors.grey.shade600,
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

            // Mapa de niveles con conectores LED integrados
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 30),
                itemCount: totalLevels,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isCompleted = levelNumber < currentLevel;
                  final isUnlocked = levelNumber <= currentLevel;
                  final offset = _getOffset(index);

                  // Calculamos el offset del siguiente nivel para el conector
                  final bool hasNext = index < totalLevels - 1;
                  final double nextOffset = hasNext ? _getOffset(index + 1) : 0;
                  final bool nextIsCompleted = hasNext && (index + 2) < currentLevel;
                  final bool currentIsActive = levelNumber < currentLevel;

                  return SizedBox(
                    height: 120,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Conector LED hacia el siguiente nivel (arriba)
                        if (hasNext)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ConnectorPainter(
                                fromOffset: offset,
                                toOffset: nextOffset,
                                isActive: currentIsActive,
                                activeColor: courseColor,
                              ),
                            ),
                          ),
                        // Nodo del nivel
                        Center(
                          child: LevelNode(
                            levelNumber: levelNumber,
                            isCompleted: isCompleted,
                            isUnlocked: isUnlocked,
                            offset: offset,
                            courseColor: courseColor,
                            onTap: () => context.push('/lesson/$levelNumber'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinta el conector LED entre un nodo y el siguiente
class _ConnectorPainter extends CustomPainter {
  final double fromOffset;
  final double toOffset;
  final bool isActive;
  final Color activeColor;

  _ConnectorPainter({
    required this.fromOffset,
    required this.toOffset,
    required this.isActive,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Posición X del nodo actual y del siguiente
    final startX = centerX + (fromOffset * size.width * 0.4);
    final endX = centerX + (toOffset * size.width * 0.4);

    // El conector va desde la parte superior del nodo actual (centro) hacia arriba
    final start = Offset(startX, 20); // Parte superior de este item
    final end = Offset(endX, -60);    // Parte inferior del item de arriba (en el ListView invertido: arriba = siguiente)

    final color = isActive ? activeColor : const Color(0xFF2A3060);

    // Glow (solo si activo)
    if (isActive) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.25)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawLine(start, end, glowPaint);
    }

    // Línea principal
    final mainPaint = Paint()
      ..color = color.withOpacity(isActive ? 0.7 : 0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, mainPaint);

    // Línea interior brillante (efecto LED core)
    if (isActive) {
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) {
    return oldDelegate.fromOffset != fromOffset ||
        oldDelegate.toOffset != toOffset ||
        oldDelegate.isActive != isActive;
  }
}
