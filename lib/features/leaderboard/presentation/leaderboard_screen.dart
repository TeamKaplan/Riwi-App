import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/utils/league_utils.dart';

// Provider que trae el top 20 de Supabase
final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Escucha cambios en el progreso local para refrescar automáticamente
  ref.watch(progressProvider);
  final data = await Supabase.instance.client
      .from('profiles')
      .select('id, username, total_xp, streak')
      .order('total_xp', ascending: false)
      .limit(20);
  return List<Map<String, dynamic>>.from(data as List);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final cs = Theme.of(context).colorScheme;
    final leaderboard = ref.watch(leaderboardProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          isSpanish ? 'Ranking Global' : 'Global Ranking',
          style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: cs.onSurfaceVariant),
            onPressed: () => ref.refresh(leaderboardProvider),
          ),
        ],
      ),
      body: leaderboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                isSpanish
                    ? 'Sin conexión. Intenta de nuevo.'
                    : 'No connection. Try again.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(leaderboardProvider),
                child: Text(isSpanish ? 'Reintentar' : 'Retry'),
              ),
            ],
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Text(
                isSpanish
                    ? 'Aún no hay usuarios en el ranking.'
                    : 'No users in the ranking yet.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            );
          }

          return Column(
            children: [
              const SizedBox(height: 8),

              // Podio top 3
              if (users.length >= 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: _PodiumTile(
                              user: users[1],
                              rank: 2,
                              height: 75,
                              radius: 26,
                              color: const Color(0xFFB0BEC5),
                              isCurrentUser: users[1]['id'] == currentUserId)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _PodiumTile(
                              user: users[0],
                              rank: 1,
                              height: 105,
                              radius: 34,
                              color: const Color(0xFFFFD700),
                              isCurrentUser: users[0]['id'] == currentUserId)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _PodiumTile(
                              user: users[2],
                              rank: 3,
                              height: 55,
                              radius: 22,
                              color: const Color(0xFFCD7F32),
                              isCurrentUser: users[2]['id'] == currentUserId)),
                    ],
                  ),
                ).animate().fadeIn(duration: 700.ms).slideY(begin: -0.15),

              const SizedBox(height: 12),

              // Lista del 4 en adelante
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(top: 20, bottom: 20),
                    itemCount: users.length < 3 ? users.length : users.length - 3,
                    itemBuilder: (context, index) {
                      final user = users.length < 3
                          ? users[index]
                          : users[index + 3];
                      final rank = users.length < 3 ? index + 1 : index + 4;
                      final isMe = user['id'] == currentUserId;
                      final username = user['username'] as String? ?? '???';
                      final xp = (user['total_xp'] as num?)?.toInt() ?? 0;
                      final initials = _initials(username);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isMe
                              ? cs.primary.withOpacity(0.12)
                              : cs.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isMe ? cs.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Número de posición
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Text(
                                  '#$rank',
                                  style: TextStyle(
                                    color: isMe
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Avatar
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isMe
                                  ? cs.primary.withOpacity(0.25)
                                  : cs.surfaceContainerHighest,
                              child: Text(initials,
                                  style: TextStyle(
                                    color: isMe
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMe
                                        ? (isSpanish
                                            ? 'Tú — $username'
                                            : 'You — $username')
                                        : username,
                                    style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 15,
                                      fontWeight: isMe
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (isMe)
                                    Text(
                                      isSpanish
                                          ? '¡Sigue así! 💪'
                                          : 'Keep it up! 💪',
                                      style: TextStyle(
                                          color: cs.primary.withOpacity(0.8),
                                          fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            // League badge
                            _LeagueBadge(xp: xp),
                            const SizedBox(width: 8),
                            // XP badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? cs.primary.withOpacity(0.2)
                                    : cs.outline.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$xp XP',
                                style: TextStyle(
                                  color: isMe
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                          delay: (index * 60).ms, duration: 300.ms);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _initials(String username) {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();
  }
}

// ─── Podio ───────────────────────────────────────
class _PodiumTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  final double height;
  final double radius;
  final Color color;
  final bool isCurrentUser;

  const _PodiumTile({
    required this.user,
    required this.rank,
    required this.height,
    required this.radius,
    required this.color,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final medals = ['', '👑', '🥈', '🥉'];
    final isFirst = rank == 1;
    final username = user['username'] as String? ?? '???';
    final xp = (user['total_xp'] as num?)?.toInt() ?? 0;
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medals[rank], style: TextStyle(fontSize: isFirst ? 36 : 22)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isFirst ? 4 : 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isFirst ? 0.6 : 0.3),
                blurRadius: isFirst ? 20 : 10,
                spreadRadius: isFirst ? 4 : 1,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor:
                isCurrentUser ? color.withOpacity(0.2) : cs.surfaceContainerHighest,
            child: Text(
              initials,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.55,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          username.split(' ').first,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isFirst ? 15 : 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LeagueBadge(xp: xp, size: isFirst ? 16 : 13),
            const SizedBox(width: 4),
            Text(
              '$xp XP',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isFirst ? 14 : 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            children: [
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: height - 6,
                  decoration: BoxDecoration(
                    color: HSLColor.fromColor(color).withLightness(0.15).toColor(),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                ),
              ),
              Positioned(
                left: 0, right: 0, top: 0,
                child: Container(
                  height: height - 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(color, Colors.white, isFirst ? 0.2 : 0.1)!,
                        color.withOpacity(isFirst ? 0.9 : 0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isFirst ? 32 : 24,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── League badge ─────────────────────────────────
class _LeagueBadge extends StatelessWidget {
  final int xp;
  final double size;

  const _LeagueBadge({required this.xp, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final league = leagueForXP(xp);
    return Icon(league.icon, color: league.color, size: size);
  }
}
