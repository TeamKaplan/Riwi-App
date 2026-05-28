import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_kaplan/shared/widgets/level_node.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/providers/levels_provider.dart';
import '../../../core/services/levels_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// ─── Datos de intro por curso ────────────────────────────────────────────────
const _introData = [
  {
    'titleEs': '¡Bienvenido a Inglés!',
    'titleEn': 'Welcome to English!',
    'descEs': 'Domina el idioma del mundo paso a paso. Cada nivel te acerca más a hablar con fluidez y confianza. ¡Tú puedes hacerlo! 🌍',
    'descEn': 'Master the world\'s language step by step. Each level brings you closer to speaking fluently and confidently. You\'ve got this! 🌍',
    'levels': 23,
    'emoji': '🌍',
  },
  {
    'titleEs': '¡Bienvenido a Desarrollo!',
    'titleEn': 'Welcome to Development!',
    'descEs': 'Aprenderás Python, el lenguaje más demandado del mundo. De variables y funciones hasta proyectos reales. ¡El mundo tech te espera y tú estás listo! 🐍',
    'descEn': 'You\'ll learn Python, the world\'s most in-demand language. From variables and functions to real projects. The tech world awaits — and you\'re ready! 🐍',
    'levels': 5,
    'emoji': '🐍',
  },
  {
    'titleEs': '¡Bienvenido a Soft Skills!',
    'titleEn': 'Welcome to Soft Skills!',
    'descEs': 'Las habilidades que ningún algoritmo puede reemplazar. Comunicación, liderazgo, trabajo en equipo. ¡Invierte en ti y marca la diferencia! 🚀',
    'descEn': 'The skills no algorithm can replace. Communication, leadership, teamwork. Invest in yourself and make a difference! 🚀',
    'levels': 5,
    'emoji': '🚀',
  },
];

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCourse = 0;
  final Set<int> _introChecked = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowRiwiIntro());
  }

  Future<void> _maybeShowRiwiIntro() async {
    if (!mounted) return;
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final riwiKey = 'intro_riwi_$userId';

    if (prefs.getBool(riwiKey) != true) {
      await prefs.setBool(riwiKey, true);
      if (mounted) {
        await _showRiwiIntroDialog();
        if (mounted) await _maybeShowIntro();
      }
    } else {
      await _maybeShowIntro();
    }
  }

  Future<void> _showRiwiIntroDialog() async {
    final isSpanish = ref.read(localeProvider).languageCode == 'es';
    final cs = Theme.of(context).colorScheme;
    const color = Color(0xFF6B5BFC);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 40, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo RIWI
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B5BFC), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: const Center(
                  child: Text('🎓', style: TextStyle(fontSize: 48)),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: 20),

              Text(
                isSpanish ? '¡Bienvenido a RIWI!' : 'Welcome to RIWI!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 12),

              Text(
                isSpanish
                    ? 'Tu plataforma de aprendizaje. Avanza a tu ritmo, gana XP, sube de liga y conviértete en la mejor versión de ti mismo. ¡El conocimiento es tu superpoder!'
                    : 'Your learning platform. Go at your own pace, earn XP, climb the leagues, and become the best version of yourself. Knowledge is your superpower!',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 20),

              // Los 3 cursos como chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CourseChip(emoji: '🌍', label: isSpanish ? 'Inglés' : 'English', color: const Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  _CourseChip(emoji: '🐍', label: isSpanish ? 'Dev' : 'Dev', color: const Color(0xFF6B5BFC)),
                  const SizedBox(width: 8),
                  _CourseChip(emoji: '🚀', label: 'Soft Skills', color: const Color(0xFFFF7043)),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isSpanish ? '¡Empecemos! 🎉' : 'Let\'s start! 🎉',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _maybeShowIntro() async {
    if (!mounted || _introChecked.contains(_selectedCourse)) return;
    _introChecked.add(_selectedCourse);

    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final key = 'intro_seen_${userId}_$_selectedCourse';

    if (prefs.getBool(key) != true) {
      await prefs.setBool(key, true);
      if (mounted) _showIntroDialog();
    }
  }

  void _showIntroDialog() {
    final isSpanish = ref.read(localeProvider).languageCode == 'es';
    final courses = _getCourses(isSpanish);
    final course = courses[_selectedCourse];
    final data = _introData[_selectedCourse];
    final color = course['color'] as Color;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.25), blurRadius: 32, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono grande animado
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                ),
                child: Center(
                  child: Text(
                    data['emoji'] as String,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 20),

              // Título
              Text(
                isSpanish ? data['titleEs'] as String : data['titleEn'] as String,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: 14),

              // Descripción motivadora
              Text(
                isSpanish ? data['descEs'] as String : data['descEn'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Chip con número de niveles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.layers_rounded, color: color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isSpanish
                          ? '${data['levels']} niveles · +XP por lección'
                          : '${data['levels']} levels · +XP per lesson',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Botón CTA
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isSpanish ? '¡Vamos! 🔥' : 'Let\'s go! 🔥',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCourses(bool isSpanish) {
    int count(int courseIndex) => ref.read(levelsProvider(courseIndex)).value?.length
        ?? LevelsService.localLevels(courseIndex).length;

    return [
      {
        'name':   isSpanish ? 'Inglés' : 'English',
        'icon':   Icons.translate,
        'color':  const Color(0xFF4CAF50),
        'levels': count(0),
      },
      {
        'name':   isSpanish ? 'Desarrollo' : 'Development',
        'icon':   Icons.code,
        'color':  const Color(0xFF6B5BFC),
        'levels': count(1),
      },
      {
        'name':   'Soft Skills',
        'icon':   Icons.psychology,
        'color':  const Color(0xFFFF7043),
        'levels': count(2),
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
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _showIntroDialog,
              child: Icon(Icons.info_outline_rounded, color: courseColor.withOpacity(0.7), size: 19),
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
                        onTap: () {
                          setState(() => _selectedCourse = index);
                          WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowIntro());
                        },
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

class _CourseChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _CourseChip({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
