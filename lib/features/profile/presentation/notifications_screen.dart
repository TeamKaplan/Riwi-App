import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final settings = ref.watch(notificationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          isSpanish ? 'Notificaciones' : 'Notifications',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationSection(
            context,
            title: isSpanish ? 'General' : 'General',
            items: [
              _buildSwitchTile(
                context,
                title: isSpanish ? 'Recordatorios diarios' : 'Daily reminders',
                subtitle: isSpanish 
                    ? 'Recibe una notificación para no perder tu racha' 
                    : 'Get a notification to keep your streak',
                value: settings.dailyReminders,
                onChanged: (_) => ref.read(notificationsProvider.notifier).toggleDailyReminders(),
                icon: Icons.alarm,
              ),
              _buildSwitchTile(
                context,
                title: isSpanish ? 'Actualizaciones de la app' : 'App updates',
                subtitle: isSpanish 
                    ? 'Entérate de nuevas lecciones y funciones' 
                    : 'Learn about new lessons and features',
                value: settings.appUpdates,
                onChanged: (_) => ref.read(notificationsProvider.notifier).toggleAppUpdates(),
                icon: Icons.system_update,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNotificationSection(
            context,
            title: isSpanish ? 'Competición' : 'Competition',
            items: [
              _buildSwitchTile(
                context,
                title: isSpanish ? 'Ranking de Liga' : 'League Ranking',
                subtitle: isSpanish 
                    ? 'Avisos cuando alguien te supera o cambia la liga' 
                    : 'Alerts when someone passes you or the league changes',
                value: settings.leagueRanking,
                onChanged: (_) => ref.read(notificationsProvider.notifier).toggleLeagueRanking(),
                icon: Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, {required String title, required List<Widget> items}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: colorScheme.primary,
    );
  }
}
