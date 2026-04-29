import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static final List<Map<String, dynamic>> _users = [
    {'name': 'María García', 'xp': 4520, 'initials': 'MG'},
    {'name': 'Carlos López', 'xp': 4100, 'initials': 'CL'},
    {'name': 'Ana Rodríguez', 'xp': 3800, 'initials': 'AR'},
    {'name': 'Tú - Coder RIWI', 'xp': 1200, 'initials': 'CR'},
    {'name': 'David Martínez', 'xp': 1150, 'initials': 'DM'},
    {'name': 'Laura Sánchez', 'xp': 1080, 'initials': 'LS'},
    {'name': 'Pedro Ruiz', 'xp': 980, 'initials': 'PR'},
    {'name': 'Sofía Torres', 'xp': 870, 'initials': 'ST'},
    {'name': 'Miguel Díaz', 'xp': 750, 'initials': 'MD'},
    {'name': 'Elena Moreno', 'xp': 620, 'initials': 'EM'},
    {'name': 'Julián Herrera', 'xp': 510, 'initials': 'JH'},
    {'name': 'Camila Vargas', 'xp': 430, 'initials': 'CV'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171B36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171B36),
        elevation: 0,
        title: const Text(
          'Ranking Semanal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF23294C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text('Liga Oro', style: TextStyle(color: Colors.amber.shade300, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // ===== PODIO TOP 3 =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2do lugar
                Expanded(
                  child: _buildPodiumPlayer(
                    user: _users[1],
                    rank: 2,
                    podiumHeight: 75,
                    avatarRadius: 26,
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
                const SizedBox(width: 6),
                // 1er lugar
                Expanded(
                  child: _buildPodiumPlayer(
                    user: _users[0],
                    rank: 1,
                    podiumHeight: 105,
                    avatarRadius: 34,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 6),
                // 3er lugar
                Expanded(
                  child: _buildPodiumPlayer(
                    user: _users[2],
                    rank: 3,
                    podiumHeight: 55,
                    avatarRadius: 22,
                    color: const Color(0xFFCD7F32),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 700.ms).slideY(begin: -0.15),

          const SizedBox(height: 12),

          // ===== LISTA DEL 4 EN ADELANTE =====
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E2344),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                itemCount: _users.length - 3,
                itemBuilder: (context, index) {
                  final user = _users[index + 3];
                  final rank = index + 4;
                  final isCurrentUser = user['name'].toString().contains('Tú');

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? const Color(0xFF6B5BFC).withOpacity(0.15)
                          : const Color(0xFF23294C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrentUser ? const Color(0xFF6B5BFC) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentUser
                                ? const Color(0xFF6B5BFC)
                                : Colors.grey.shade800,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                color: isCurrentUser ? Colors.white : Colors.grey.shade400,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isCurrentUser
                              ? const Color(0xFF6B5BFC).withOpacity(0.3)
                              : const Color(0xFF2A3160),
                          child: Text(
                            user['initials'] as String,
                            style: TextStyle(
                              color: isCurrentUser ? const Color(0xFF6B5BFC) : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] as String,
                                style: TextStyle(
                                  color: isCurrentUser ? Colors.white : Colors.grey.shade300,
                                  fontSize: 15,
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              if (isCurrentUser)
                                Text(
                                  '¡Esa eres tú! 💪',
                                  style: TextStyle(
                                    color: const Color(0xFF6B5BFC).withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? const Color(0xFF6B5BFC).withOpacity(0.2)
                                : Colors.grey.shade800.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${user['xp']} XP',
                            style: TextStyle(
                              color: isCurrentUser ? const Color(0xFF6B5BFC) : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (index * 80).ms, duration: 350.ms).slideX(begin: 0.05);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlayer({
    required Map<String, dynamic> user,
    required int rank,
    required double podiumHeight,
    required double avatarRadius,
    required Color color,
  }) {
    final medals = ['', '👑', '🥈', '🥉'];
    final isFirst = rank == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
        children: [
          // Medal / Crown
          Text(medals[rank], style: TextStyle(fontSize: isFirst ? 36 : 22)),
          const SizedBox(height: 4),

          // Avatar con glow para el primero
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: isFirst ? 4 : 3),
              boxShadow: isFirst
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: const Color(0xFF23294C),
              child: Text(
                user['initials'] as String,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: avatarRadius * 0.55,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Nombre
          Text(
            user['name'].toString().split(' ').first,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 16 : 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          // XP
          Text(
            '${user['xp']} XP',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 15 : 12,
            ),
          ),
          const SizedBox(height: 8),

          // Bloque del podio 3D
          SizedBox(
            width: double.infinity,
            height: podiumHeight,
            child: Stack(
              children: [
                // Base 3D (sombra inferior)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: podiumHeight - 6,
                    decoration: BoxDecoration(
                      color: HSLColor.fromColor(color).withLightness(0.15).toColor(),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                  ),
                ),
                // Cara superior 3D
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: podiumHeight - 8,
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
                            Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
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
