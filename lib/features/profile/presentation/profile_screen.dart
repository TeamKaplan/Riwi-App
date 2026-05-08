import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../core/providers/sound_provider.dart';
import '../../learning/data/progress_provider.dart';
import '../../auth/data/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isSpanish = currentLocale.languageCode == 'es';
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final progressState = ref.watch(progressProvider);
    final currentStreak = progressState.value?['streak']?.toString() ?? '0';
    final currentXp = progressState.value?['xp']?.toString() ?? '0';
    final fullName = progressState.value?['full_name'] ?? 'Coder RIWI';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          isSpanish ? 'Mi Cuenta' : 'My Account',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              _showSettingsSheet(context, ref, isSpanish);
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
            CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.person, size: 48, color: Colors.white),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 14),
            Text(
              fullName,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSpanish ? '@${fullName.toLowerCase().replaceAll(' ', '_')} • Nivel 1' : '@${fullName.toLowerCase().replaceAll(' ', '_')} • Level 1',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              isSpanish ? 'Se unió recientemente' : 'Joined recently',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),

            const SizedBox(height: 24),

            // Estadísticas
            Row(
              children: [
                _buildStatCard(
                  context,
                  Icons.local_fire_department,
                  currentStreak,
                  isSpanish ? 'Racha\nactual' : 'Current\nstreak',
                  Colors.orange,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  Icons.star_rounded,
                  currentXp,
                  isSpanish ? 'XP\ntotal' : 'Total\nXP',
                  Colors.amber,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  Icons.emoji_events,
                  isSpanish ? 'Bronce' : 'Bronze',
                  isSpanish ? 'Liga\nactual' : 'Current\nleague',
                  const Color(0xFFCD7F32),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  Icons.check_circle,
                  '0',
                  isSpanish ? 'Lecciones\nhechas' : 'Lessons\ndone',
                  Colors.green,
                ),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // Logros
            _buildSectionTitle(context, isSpanish ? 'Logros' : 'Achievements'),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAchievementBadge(
                    context,
                    Icons.local_fire_department,
                    isSpanish ? 'Racha de 7' : '7 Day Streak',
                    Colors.orange,
                    false,
                  ),
                  _buildAchievementBadge(
                    context,
                    Icons.school,
                    isSpanish ? 'Primera lección' : 'First lesson',
                    colorScheme.primary,
                    false,
                  ),
                  _buildAchievementBadge(
                    context,
                    Icons.code,
                    'Coder Jr.',
                    Colors.cyan,
                    false,
                  ),
                  _buildAchievementBadge(
                    context,
                    Icons.translate,
                    isSpanish ? '50 traducciones' : '50 translations',
                    Colors.green,
                    false,
                  ),
                  _buildAchievementBadge(
                    context,
                    Icons.psychology,
                    isSpanish ? 'Empatía Pro' : 'Pro Empathy',
                    Colors.pink,
                    false,
                  ),
                  _buildAchievementBadge(
                    context,
                    Icons.diamond,
                    isSpanish ? 'Liga Diamante' : 'Diamond League',
                    Colors.cyan,
                    false,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: 24),

            // Progreso por curso
            _buildSectionTitle(context, isSpanish ? 'Progreso por Curso' : 'Course Progress'),
            const SizedBox(height: 12),
            _buildCourseProgress(context, isSpanish ? 'Inglés' : 'English', Icons.translate, 0, 20, Colors.green),
            const SizedBox(height: 10),
            _buildCourseProgress(
                context, isSpanish ? 'Desarrollo' : 'Development', Icons.code, 0, 15, colorScheme.primary),
            const SizedBox(height: 10),
            _buildCourseProgress(context, 'Soft Skills', Icons.psychology, 0, 12, Colors.deepOrange),

            const SizedBox(height: 24),

            // Opciones de cuenta
            _buildSectionTitle(context, isSpanish ? 'Configuración' : 'Settings'),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              Icons.notifications_outlined,
              isSpanish ? 'Notificaciones' : 'Notifications',
              isSpanish ? 'Recordatorios diarios' : 'Daily reminders',
              onTap: () => context.push('/notifications'),
            ),
            _buildSettingItem(
              context,
              Icons.language,
              isSpanish ? 'Idioma de la app' : 'App Language',
              isSpanish ? 'Español' : 'English',
              onTap: () => _showLanguageDialog(context, ref),
            ),
            _buildSettingItem(
              context,
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              isSpanish ? 'Modo de visualización' : 'Display Mode',
              isSpanish
                  ? (isDarkMode ? 'Oscuro' : 'Claro')
                  : (isDarkMode ? 'Dark' : 'Light'),
              onTap: () {
                ref.read(themeProvider.notifier).state =
                    isDarkMode ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            _buildSettingItem(
              context,
              Icons.volume_up_outlined,
              isSpanish ? 'Sonidos' : 'Sounds',
              isSpanish ? 'Activados' : 'Enabled',
              onTap: () => context.push('/sounds'),
            ),
            _buildSettingItem(
              context,
              Icons.privacy_tip_outlined,
              isSpanish ? 'Privacidad' : 'Privacy',
              isSpanish ? 'Perfil público' : 'Public profile',
              onTap: () {},
            ),
            _buildSettingItem(
              context,
              Icons.help_outline,
              isSpanish ? 'Ayuda y soporte' : 'Help & Support',
              '',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildLogoutButton(context, ref, isSpanish),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Seleccionar Idioma / Select Language',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Español', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('es');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('English', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String value, String label, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, IconData icon, String label, Color color, bool unlocked) {
    final colorScheme = Theme.of(context).colorScheme;
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
              color: unlocked ? color.withOpacity(0.2) : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: unlocked ? color : colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: unlocked ? color : colorScheme.outline,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked ? colorScheme.onSurface : colorScheme.outline,
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

  Widget _buildCourseProgress(
      BuildContext context, String name, IconData icon, int completed, int total, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                    Text(
                      name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text('$completed/$total', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completed / total,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
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

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle,
      {required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        title: Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12))
            : null,
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, bool isSpanish) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(authProvider.notifier).signOut();
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text(isSpanish ? 'Cerrar Sesión' : 'Logout', style: const TextStyle(fontSize: 16)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade400,
          side: BorderSide(color: Colors.red.shade400),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref, bool isSpanish) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isSpanish ? 'Ajustes rápidos' : 'Quick Settings',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleTile(
                    context,
                    isSpanish ? 'Recordatorio diario' : 'Daily reminder',
                    Icons.alarm,
                    ref.watch(notificationsProvider).dailyReminders,
                    onChanged: (val) => ref.read(notificationsProvider.notifier).toggleDailyReminders(),
                  ),
                  _buildToggleTile(
                    context,
                    isSpanish ? 'Sonidos de la app' : 'App sounds',
                    Icons.volume_up,
                    !ref.watch(soundProvider).isMuted,
                    onChanged: (val) => ref.read(soundProvider.notifier).toggleMute(),
                  ),
                  _buildToggleTile(
                    context,
                    isSpanish ? 'Vibración' : 'Vibration',
                    Icons.vibration,
                    false,
                    onChanged: (val) {},
                  ),
                  _buildToggleTile(
                    context,
                    isSpanish ? 'Modo offline' : 'Offline mode',
                    Icons.wifi_off,
                    false,
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleTile(BuildContext context, String title, IconData icon, bool value,
      {required ValueChanged<bool> onChanged}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
        ],
      ),
      value: value,
      activeThumbColor: colorScheme.primary,
      onChanged: onChanged,
    );
  }
}
