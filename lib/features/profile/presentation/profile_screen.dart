import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171B36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171B36),
        elevation: 0,
        title: const Text('Mi Cuenta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              _showSettingsSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Avatar y nombre
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF6B5BFC),
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 14),
            const Text(
              'Coder RIWI',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '@coder_riwi • Nivel 5',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Se unió en abril 2026',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),

            const SizedBox(height: 24),

            // Estadísticas
            Row(
              children: [
                _buildStatCard(Icons.local_fire_department, '12', 'Racha\nactual', Colors.orange),
                const SizedBox(width: 10),
                _buildStatCard(Icons.star_rounded, '1,200', 'XP\ntotal', Colors.amber),
                const SizedBox(width: 10),
                _buildStatCard(Icons.emoji_events, 'Oro', 'Liga\nactual', const Color(0xFFFFD700)),
                const SizedBox(width: 10),
                _buildStatCard(Icons.check_circle, '14', 'Lecciones\nhechas', Colors.green),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // Logros
            _buildSectionTitle('Logros'),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAchievementBadge(Icons.local_fire_department, 'Racha de 7', Colors.orange, true),
                  _buildAchievementBadge(Icons.school, 'Primera lección', const Color(0xFF6B5BFC), true),
                  _buildAchievementBadge(Icons.code, 'Coder Jr.', Colors.cyan, true),
                  _buildAchievementBadge(Icons.translate, '50 traducciones', Colors.green, false),
                  _buildAchievementBadge(Icons.psychology, 'Empatía Pro', Colors.pink, false),
                  _buildAchievementBadge(Icons.diamond, 'Liga Diamante', Colors.cyan, false),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: 24),

            // Progreso por curso
            _buildSectionTitle('Progreso por Curso'),
            const SizedBox(height: 12),
            _buildCourseProgress('Inglés', Icons.translate, 5, 20, Colors.green),
            const SizedBox(height: 10),
            _buildCourseProgress('Desarrollo', Icons.code, 3, 15, const Color(0xFF6B5BFC)),
            const SizedBox(height: 10),
            _buildCourseProgress('Soft Skills', Icons.psychology, 2, 12, Colors.deepOrange),

            const SizedBox(height: 24),

            // Opciones de cuenta
            _buildSectionTitle('Configuración'),
            const SizedBox(height: 12),
            _buildSettingItem(Icons.notifications_outlined, 'Notificaciones', 'Recordatorios diarios', context),
            _buildSettingItem(Icons.language, 'Idioma de la app', 'Español', context),
            _buildSettingItem(Icons.dark_mode_outlined, 'Tema oscuro', 'Activado', context),
            _buildSettingItem(Icons.volume_up_outlined, 'Sonidos', 'Activados', context),
            _buildSettingItem(Icons.privacy_tip_outlined, 'Privacidad', 'Perfil público', context),
            _buildSettingItem(Icons.help_outline, 'Ayuda y soporte', '', context),
            const SizedBox(height: 12),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF23294C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label, Color color, bool unlocked) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? color.withOpacity(0.2) : Colors.grey.shade800,
              border: Border.all(
                color: unlocked ? color : Colors.grey.shade700,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: unlocked ? color : Colors.grey.shade600,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.grey.shade600,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgress(String name, IconData icon, int completed, int total, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF23294C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('$completed/$total', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completed / total,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF23294C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6B5BFC), size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {},
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade400,
          side: BorderSide(color: Colors.red.shade400),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2344),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ajustes rápidos',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildToggleTile('Recordatorio diario', Icons.alarm, true),
              _buildToggleTile('Sonidos de la app', Icons.volume_up, true),
              _buildToggleTile('Vibración', Icons.vibration, false),
              _buildToggleTile('Modo offline', Icons.wifi_off, false),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleTile(String title, IconData icon, bool defaultVal) {
    return StatefulBuilder(
      builder: (context, setTileState) {
        bool isOn = defaultVal;
        return SwitchListTile(
          title: Row(
            children: [
              Icon(icon, color: const Color(0xFF6B5BFC), size: 22),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
          value: isOn,
          activeColor: const Color(0xFF6B5BFC),
          onChanged: (val) {
            setTileState(() {
              isOn = val;
            });
          },
        );
      },
    );
  }
}
