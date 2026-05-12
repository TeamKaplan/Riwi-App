import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/utils/league_utils.dart';

final leagueMatesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final progress = ref.watch(progressProvider);
  final league = leagueForXP(progress.totalXP);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  final maxXP = league.maxXP == 999999 ? 9999999 : league.maxXP;
  final data = await Supabase.instance.client
      .from('profiles')
      .select('id, username, total_xp, streak')
      .gte('total_xp', league.minXP)
      .lte('total_xp', maxXP)
      .order('total_xp', ascending: false)
      .limit(20);

  return List<Map<String, dynamic>>.from(data as List)
      .where((u) => u['id'] != currentUserId)
      .toList();
});

class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final cs = Theme.of(context).colorScheme;
    final progress = ref.watch(progressProvider);
    final leagueMates = ref.watch(leagueMatesProvider);

    final userXP = progress.totalXP;
    final currentLeague = leagueForXP(userXP);
    final nextLeague = nextLeagueForXP(userXP);
    final progressValue = leagueProgress(userXP);
    final currentColor = currentLeague.color;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          isSpanish ? 'Ligas' : 'Leagues',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: cs.onSurfaceVariant),
            onPressed: () => ref.refresh(leagueMatesProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── CARD LIGA ACTUAL ──
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
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                    ),
                    child: Icon(currentLeague.icon, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isSpanish ? 'Liga' : 'League'} ${currentLeague.name(isSpanish)}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSpanish ? '$userXP XP acumulados' : '$userXP XP accumulated',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.92, 0.92)),

            const SizedBox(height: 24),

            // ── PROGRESO HACIA SIGUIENTE LIGA ──
            if (nextLeague != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outline.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: nextLeague.color, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isSpanish
                              ? 'Progreso hacia ${nextLeague.nameEs}'
                              : 'Progress towards ${nextLeague.nameEn}',
                          style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _LeagueIcon(league: currentLeague, size: 36, iconSize: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 14,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: progressValue,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [currentColor, nextLeague.color]),
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
                                  Text('$userXP XP', style: TextStyle(color: currentColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('${nextLeague.minXP} XP', style: TextStyle(color: nextLeague.color, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _LeagueIcon(league: nextLeague, size: 36, iconSize: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        isSpanish
                            ? 'Te faltan ${nextLeague.minXP - userXP} XP para ascender 🚀'
                            : 'You need ${nextLeague.minXP - userXP} more XP to promote 🚀',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 28),

            // ── COMPAÑEROS DE LIGA ──
            Row(
              children: [
                Icon(Icons.people_alt_rounded, color: currentColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  isSpanish ? 'Compañeros de liga' : 'League mates',
                  style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            leagueMates.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  isSpanish ? 'No se pudo cargar.' : 'Could not load.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              data: (mates) {
                if (mates.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      isSpanish
                          ? '¡Eres el único en tu liga por ahora!'
                          : "You're the only one in your league for now!",
                      style: TextStyle(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Column(
                  children: List.generate(mates.length, (i) {
                    final mate = mates[i];
                    final username = mate['username'] as String? ?? '???';
                    final mateXP = mate['total_xp'] as int? ?? 0;
                    final initials = username.length >= 2
                        ? username.substring(0, 2).toUpperCase()
                        : username.toUpperCase();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: currentColor.withOpacity(0.2),
                            child: Text(initials, style: TextStyle(color: currentColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(username, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500, fontSize: 15)),
                          ),
                          Text('$mateXP XP', style: TextStyle(color: currentColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms);
                  }),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── TODAS LAS LIGAS ──
            Text(
              isSpanish ? 'Todas las Ligas' : 'All Leagues',
              style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            ...List.generate(kLeagues.length, (i) {
              // Display Diamond → Bronze (reversed)
              final league = kLeagues[kLeagues.length - 1 - i];
              final isCurrent = league == currentLeague;
              final isAchieved = league.minXP < currentLeague.minXP;
              final isLocked = league.minXP > currentLeague.minXP;
              final color = league.color;
              final maxLabel = league.maxXP == 999999 ? '∞' : '${league.maxXP}';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withOpacity(0.12) : cs.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrent
                      ? Border.all(color: color, width: 2)
                      : Border.all(color: cs.outline.withOpacity(0.1), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked ? cs.outline.withOpacity(0.1) : color.withOpacity(0.2),
                      ),
                      child: Icon(league.icon, color: isLocked ? cs.outline : color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            league.name(isSpanish),
                            style: TextStyle(
                              color: isLocked ? cs.outline : cs.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${league.minXP} – $maxLabel XP',
                            style: TextStyle(
                              color: isLocked ? cs.outline.withOpacity(0.7) : cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          isSpanish ? 'ACTUAL' : 'CURRENT',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                        ),
                      )
                    else if (isAchieved)
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.2)),
                        child: const Icon(Icons.check, color: Colors.green, size: 18),
                      )
                    else
                      Icon(Icons.lock_outline, color: cs.outline, size: 22),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 100).ms, duration: 400.ms);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LeagueIcon extends StatelessWidget {
  final LeagueInfo league;
  final double size;
  final double iconSize;

  const _LeagueIcon({required this.league, required this.size, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: league.color.withOpacity(0.2)),
      child: Icon(league.icon, color: league.color, size: iconSize),
    );
  }
}
