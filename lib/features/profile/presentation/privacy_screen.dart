import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../../core/providers/progress_provider.dart';

// ── Provider de configuración de privacidad ───────────────────────────────
final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, PrivacySettings>((ref) {
  return PrivacyNotifier();
});

class PrivacySettings {
  final bool publicProfile;
  final bool showStreakPublic;
  final bool showInLeagues;

  const PrivacySettings({
    this.publicProfile = true,
    this.showStreakPublic = true,
    this.showInLeagues = true,
  });

  PrivacySettings copyWith({
    bool? publicProfile,
    bool? showStreakPublic,
    bool? showInLeagues,
  }) =>
      PrivacySettings(
        publicProfile: publicProfile ?? this.publicProfile,
        showStreakPublic: showStreakPublic ?? this.showStreakPublic,
        showInLeagues: showInLeagues ?? this.showInLeagues,
      );
}

class PrivacyNotifier extends StateNotifier<PrivacySettings> {
  static const _keyPublic  = 'privacy_public_profile';
  static const _keyStreak  = 'privacy_show_streak';
  static const _keyLeagues = 'privacy_show_leagues';

  PrivacyNotifier() : super(const PrivacySettings()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = PrivacySettings(
      publicProfile:    p.getBool(_keyPublic)  ?? true,
      showStreakPublic: p.getBool(_keyStreak)  ?? true,
      showInLeagues:    p.getBool(_keyLeagues) ?? true,
    );
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyPublic,  state.publicProfile);
    await p.setBool(_keyStreak,  state.showStreakPublic);
    await p.setBool(_keyLeagues, state.showInLeagues);
  }

  void togglePublicProfile()    { state = state.copyWith(publicProfile: !state.publicProfile);       _save(); }
  void toggleShowStreak()       { state = state.copyWith(showStreakPublic: !state.showStreakPublic);   _save(); }
  void toggleShowInLeagues()    { state = state.copyWith(showInLeagues: !state.showInLeagues);         _save(); }
}

// ── Pantalla ──────────────────────────────────────────────────────────────
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final privacy   = ref.watch(privacyProvider);
    final cs        = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isSpanish ? 'Privacidad' : 'Privacy',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Visibilidad ────────────────────────────────────────
          _sectionHeader(isSpanish ? 'Visibilidad' : 'Visibility', cs)
              .animate().fadeIn(duration: 400.ms),

          _switchTile(
            context: context,
            icon: Icons.person_outline,
            title: isSpanish ? 'Perfil público' : 'Public profile',
            subtitle: isSpanish
                ? 'Apareces en el ranking global'
                : 'You appear in the global ranking',
            value: privacy.publicProfile,
            onChanged: (_) => ref.read(privacyProvider.notifier).togglePublicProfile(),
            cs: cs,
          ).animate().fadeIn(delay: 80.ms),

          _switchTile(
            context: context,
            icon: Icons.local_fire_department_outlined,
            title: isSpanish ? 'Mostrar racha' : 'Show streak',
            subtitle: isSpanish
                ? 'Otros ven tu racha en el ranking'
                : 'Others see your streak in the ranking',
            value: privacy.showStreakPublic,
            onChanged: (_) => ref.read(privacyProvider.notifier).toggleShowStreak(),
            cs: cs,
          ).animate().fadeIn(delay: 140.ms),

          _switchTile(
            context: context,
            icon: Icons.people_outline,
            title: isSpanish ? 'Visible en ligas' : 'Visible in leagues',
            subtitle: isSpanish
                ? 'Apareces entre los compañeros de liga'
                : 'You appear among league mates',
            value: privacy.showInLeagues,
            onChanged: (_) => ref.read(privacyProvider.notifier).toggleShowInLeagues(),
            cs: cs,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // ── Datos personales ───────────────────────────────────
          _sectionHeader(isSpanish ? 'Tus datos' : 'Your data', cs)
              .animate().fadeIn(delay: 260.ms),

          _infoCard(
            context: context,
            icon: Icons.shield_outlined,
            title: isSpanish ? 'Datos que guardamos' : 'Data we store',
            body: isSpanish
                ? '• Nombre de usuario\n• Correo electrónico\n• Progreso de lecciones\n• XP y racha\n\nNunca vendemos ni compartimos tus datos con terceros.'
                : '• Username\n• Email address\n• Lesson progress\n• XP and streak\n\nWe never sell or share your data with third parties.',
            cs: cs,
          ).animate().fadeIn(delay: 320.ms),

          const SizedBox(height: 12),

          _infoCard(
            context: context,
            icon: Icons.lock_outline,
            title: isSpanish ? 'Seguridad' : 'Security',
            body: isSpanish
                ? 'Tu contraseña está cifrada con bcrypt. Supabase cumple con SOC 2 Type II y GDPR.'
                : 'Your password is encrypted with bcrypt. Supabase is SOC 2 Type II and GDPR compliant.',
            cs: cs,
          ).animate().fadeIn(delay: 380.ms),

          const SizedBox(height: 28),

          // ── Zona peligrosa ─────────────────────────────────────
          _sectionHeader(
            isSpanish ? 'Zona peligrosa' : 'Danger zone',
            cs,
            color: cs.error,
          ).animate().fadeIn(delay: 440.ms),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _confirmDeleteAccount(context, ref, isSpanish, cs),
            icon: Icon(Icons.delete_forever_outlined, size: 20, color: cs.error),
            label: Text(
              isSpanish ? 'Eliminar mi cuenta' : 'Delete my account',
              style: TextStyle(color: cs.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, ColorScheme cs, {Color? color}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            color: color ?? cs.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _switchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme cs,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SwitchListTile(
          secondary: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 15)),
          subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          value: value,
          activeThumbColor: cs.primary,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );

  Widget _infoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    required ColorScheme cs,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(body,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref, bool isSpanish, ColorScheme cs) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          isSpanish ? '¿Eliminar cuenta?' : 'Delete account?',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isSpanish
              ? 'Esta acción es irreversible. Se eliminarán tu perfil, progreso y todos tus datos permanentemente.'
              : 'This action is irreversible. Your profile, progress and all data will be permanently deleted.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isSpanish ? 'Cancelar' : 'Cancel',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(isSpanish ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      ref.read(progressProvider.notifier).onLogout();
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) context.go('/login');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isSpanish
              ? 'Error al eliminar. Contacta soporte.'
              : 'Error deleting. Contact support.'),
          backgroundColor: cs.error,
        ));
      }
    }
  }
}
