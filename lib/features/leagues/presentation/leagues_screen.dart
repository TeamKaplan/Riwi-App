import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  // Datos de ligas reiniciados
  static const int _userXP = 0;
  static const int _currentLeagueIndex = 4; // Bronce

  static final List<Map<String, dynamic>> _leagues = [
    {
      'name': 'Diamante',
      'nameEn': 'Diamond',
      'icon': Icons.diamond,
      'color': const Color(0xFF00BCD4),
      'minXP': 5000,
      'maxXP': 99999,
    },
    {
      'name': 'Platino',
      'nameEn': 'Platinum',
      'icon': Icons.workspace_premium,
      'color': const Color(0xFF90A4AE),
      'minXP': 3000,
      'maxXP': 4999,
    },
    {
      'name': 'Oro',
      'nameEn': 'Gold',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD700),
      'minXP': 1000,
      'maxXP': 2999,
    },
    {
      'name': 'Plata',
      'nameEn': 'Silver',
      'icon': Icons.military_tech,
      'color': const Color(0xFFC0C0C0),
      'minXP': 500,
      'maxXP': 999,
    },
    {
      'name': 'Bronce',
      'nameEn': 'Bronze',
      'icon': Icons.shield,
      'color': const Color(0xFFCD7F32),
      'minXP': 0,
      'maxXP': 499,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentLeague = _leagues[_currentLeagueIndex];
    final nextLeague = _currentLeagueIndex > 0 ? _leagues[_currentLeagueIndex - 1] : null;
    final currentColor = currentLeague['color'] as Color;
    final nextMinXP = nextLeague != null ? nextLeague['minXP'] as int : _userXP;
    final currentMinXP = currentLeague['minXP'] as int;
    final progress = (_userXP - currentMinXP) / (nextMinXP - currentMinXP);

    final String leagueName = isSpanish ? currentLeague['name'] : currentLeague['nameEn'];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          isSpanish ? 'Ligas' : 'Leagues',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== CARD PRINCIPAL DE LIGA ACTUAL =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentColor,
                    HSLColor.fromColor(currentColor).withLightness(0.35).toColor(),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: currentColor.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icono grande
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                    ),
                    child: Icon(
                      currentLeague['icon'] as IconData,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isSpanish ? 'Liga' : 'League'} $leagueName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSpanish ? '$_userXP XP acumulados' : '$_userXP XP accumulated',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.92, 0.92)),

            const SizedBox(height: 24),

            // ===== BARRA DE PROGRESO A SIGUIENTE LIGA =====
            if (nextLeague != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: (nextLeague['color'] as Color), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isSpanish
                              ? 'Progreso hacia ${nextLeague['name']}'
                              : 'Progress towards ${nextLeague['nameEn']}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Barra de progreso
                    Row(
                      children: [
                        // Liga actual (icono)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentColor.withOpacity(0.2),
                          ),
                          child: Icon(currentLeague['icon'] as IconData, color: currentColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        // Barra
                        Expanded(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 14,
                                  child: Stack(
                                    children: [
                                      // Fondo
                                      Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      // Progreso
                                      FractionallySizedBox(
                                        widthFactor: progress.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [currentColor, (nextLeague['color'] as Color)],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ).animate().scaleX(
                                        begin: 0,
                                        end: 1,
                                        duration: 1200.ms,
                                        curve: Curves.easeOutCubic,
                                        alignment: Alignment.centerLeft,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$_userXP XP',
                                    style: TextStyle(color: currentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '$nextMinXP XP',
                                    style: TextStyle(
                                      color: (nextLeague['color'] as Color),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Liga siguiente (icono)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (nextLeague['color'] as Color).withOpacity(0.2),
                          ),
                          child: Icon(nextLeague['icon'] as IconData, color: (nextLeague['color'] as Color), size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        isSpanish
                            ? 'Te faltan ${nextMinXP - _userXP} XP para ascender 🚀'
                            : 'You need ${nextMinXP - _userXP} more XP to promote 🚀',
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // ===== TÍTULO =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isSpanish ? 'Todas las Ligas' : 'All Leagues',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),

            // ===== LISTA DE LIGAS =====
            ...List.generate(_leagues.length, (index) {
              final league = _leagues[index];
              final isCurrent = index == _currentLeagueIndex;
              final isCompleted = index > _currentLeagueIndex;
              final isLocked = index < _currentLeagueIndex;
              final color = league['color'] as Color;
              final String name = isSpanish ? league['name'] : league['nameEn'];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color.withOpacity(0.12)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrent
                      ? Border.all(color: color, width: 2)
                      : Border.all(color: colorScheme.outline.withOpacity(0.1), width: 1),
                ),
                child: Row(
                  children: [
                    // Icono
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked ? colorScheme.outline.withOpacity(0.1) : color.withOpacity(0.2),
                      ),
                      child: Icon(
                        league['icon'] as IconData,
                        color: isLocked ? colorScheme.outline : color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nombre y XP
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: isLocked ? colorScheme.outline : colorScheme.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${league['minXP']} - ${league['maxXP']} XP',
                            style: TextStyle(
                              color: isLocked ? colorScheme.outline.withOpacity(0.7) : colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge de estado
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSpanish ? 'ACTUAL' : 'CURRENT',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                        ),
                      )
                    else if (isCompleted)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.2),
                        ),
                        child: const Icon(Icons.check, color: Colors.green, size: 18),
                      )
                    else
                      Icon(Icons.lock_outline, color: colorScheme.outline, size: 22),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
