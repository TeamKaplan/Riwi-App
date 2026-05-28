import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/locale_provider.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final cs        = Theme.of(context).colorScheme;
    final faqs      = _faqs(isSpanish);

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
          isSpanish ? 'Ayuda y Soporte' : 'Help & Support',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Banner ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🎓', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSpanish ? '¿Cómo podemos ayudarte?' : 'How can we help you?',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSpanish
                            ? 'Encuentra respuestas rápidas o contáctanos.'
                            : 'Find quick answers or contact us.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

          const SizedBox(height: 28),

          // ── Accesos rápidos ───────────────────────────────────
          Text(
            isSpanish ? 'Acciones rápidas' : 'Quick actions',
            style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),

          Row(
            children: [
              _quickAction(
                context,
                icon: Icons.email_outlined,
                label: isSpanish ? 'Enviar email' : 'Send email',
                onTap: () => _showContactDialog(context, isSpanish, cs),
                cs: cs,
              ),
              const SizedBox(width: 12),
              _quickAction(
                context,
                icon: Icons.bug_report_outlined,
                label: isSpanish ? 'Reportar bug' : 'Report bug',
                onTap: () => _showReportDialog(context, isSpanish, cs),
                cs: cs,
              ),
              const SizedBox(width: 12),
              _quickAction(
                context,
                icon: Icons.star_outline,
                label: isSpanish ? 'Valorar app' : 'Rate app',
                onTap: () => _showRateSnack(context, isSpanish),
                cs: cs,
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 28),

          // ── FAQ ───────────────────────────────────────────────
          Text(
            isSpanish ? 'Preguntas frecuentes' : 'Frequently asked questions',
            style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),

          ...List.generate(faqs.length, (i) {
            final faq      = faqs[i];
            final isOpen   = _expanded.contains(i);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: isOpen
                    ? Border.all(color: cs.primary.withValues(alpha: 0.4), width: 1.5)
                    : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() {
                  if (isOpen) {
                    _expanded.remove(i);
                  } else {
                    _expanded.add(i);
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq['q']!,
                              style: TextStyle(
                                color: isOpen ? cs.primary : cs.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            isOpen ? Icons.expand_less : Icons.expand_more,
                            color: isOpen ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 10),
                        Text(
                          faq['a']!,
                          style: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 13, height: 1.6),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 220 + i * 60));
          }),

          const SizedBox(height: 28),

          // ── Información de la app ─────────────────────────────
          Text(
            isSpanish ? 'Información' : 'App info',
            style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),

          _infoRow(isSpanish ? 'Versión' : 'Version', '1.0.0', cs)
              .animate().fadeIn(delay: 440.ms),
          _infoRow(isSpanish ? 'Desarrollado por' : 'Developed by', 'Team Kaplan', cs)
              .animate().fadeIn(delay: 480.ms),
          _infoRow(isSpanish ? 'Contacto' : 'Contact', 'soporte@riwi.io', cs)
              .animate().fadeIn(delay: 520.ms),
          _infoRow(isSpanish ? 'Tecnología' : 'Technology', 'Flutter + Supabase', cs)
              .animate().fadeIn(delay: 560.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icon, color: cs.primary, size: 26),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      );

  Widget _infoRow(String label, String value, ColorScheme cs) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
            Text(value,
                style: TextStyle(
                    color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showContactDialog(BuildContext context, bool isSpanish, ColorScheme cs) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          isSpanish ? 'Contactar soporte' : 'Contact support',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isSpanish
              ? 'Escríbenos a:\n\nsoporte@riwi.io\n\nResponderemos en menos de 24 horas hábiles.'
              : 'Write to us at:\n\nsupport@riwi.io\n\nWe\'ll respond within 24 business hours.',
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSpanish ? 'Entendido' : 'Got it'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, bool isSpanish, ColorScheme cs) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          isSpanish ? 'Reportar un problema' : 'Report an issue',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSpanish ? 'Describe el problema brevemente:' : 'Briefly describe the problem:',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 4,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: isSpanish ? 'Ej: La pantalla de lección se congela...' : 'E.g.: The lesson screen freezes...',
                hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(ctx); ctrl.dispose(); },
            child: Text(isSpanish ? 'Cancelar' : 'Cancel',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.dispose();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isSpanish ? '¡Reporte enviado! Gracias 🙏' : 'Report sent! Thank you 🙏'),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Text(isSpanish ? 'Enviar' : 'Send'),
          ),
        ],
      ),
    );
  }

  void _showRateSnack(BuildContext context, bool isSpanish) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isSpanish
          ? '¡Gracias por tu apoyo! 🌟 La app aún no está en tiendas.'
          : 'Thank you for your support! 🌟 The app is not in stores yet.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── FAQ data ──────────────────────────────────────────────────────────────
  List<Map<String, String>> _faqs(bool es) => es
      ? [
          {
            'q': '¿Cómo funciona el sistema de XP y ligas?',
            'a': 'Cada lección completada te da XP. Con más XP subes de liga: Bronce → Plata → Oro → Platino → Diamante. El ranking global se actualiza en tiempo real.',
          },
          {
            'q': '¿Qué pasa si pierdo mi racha?',
            'a': 'Si no completas al menos una lección por día, tu racha se reinicia a 1 al día siguiente. Intenta completar una lección todos los días para mantenerla.',
          },
          {
            'q': '¿Puedo cambiar mi nombre de usuario?',
            'a': 'Sí. Ve a Perfil → icono ✏️ → Editar Perfil. Puedes cambiar tu nombre de usuario en cualquier momento.',
          },
          {
            'q': '¿El Tutor IA necesita internet?',
            'a': 'Sí, el Tutor IA usa modelos de IA en la nube (Groq Whisper + Llama 3). Necesitas conexión activa para grabar y recibir respuestas.',
          },
          {
            'q': '¿Las lecciones funcionan sin internet?',
            'a': 'Sí. Los niveles y preguntas se cargan localmente como respaldo. Sin embargo, el progreso se sincroniza con la nube cuando recuperes conexión.',
          },
          {
            'q': '¿Cómo se calculan los logros?',
            'a': '• Racha de 7: mantén 7 días seguidos.\n• Primera lección: completa cualquier lección.\n• Coder Jr.: completa un nivel de Desarrollo.\n• 5 niveles inglés: completa 5 niveles de Inglés.\n• Empatía Pro: completa un nivel de Soft Skills.\n• Liga Diamante: acumula 5000 XP.',
          },
          {
            'q': '¿Cómo puedo restablecer mi contraseña?',
            'a': 'En la pantalla de inicio de sesión, pulsa "¿Olvidaste tu contraseña?" e ingresa tu email. Recibirás un enlace de restablecimiento.',
          },
        ]
      : [
          {
            'q': 'How does the XP and league system work?',
            'a': 'Each completed lesson gives you XP. More XP means a higher league: Bronze → Silver → Gold → Platinum → Diamond. The global ranking updates in real time.',
          },
          {
            'q': 'What happens if I lose my streak?',
            'a': 'If you don\'t complete at least one lesson per day, your streak resets to 1 the next day. Try to complete one lesson every day to keep it going.',
          },
          {
            'q': 'Can I change my username?',
            'a': 'Yes. Go to Profile → ✏️ icon → Edit Profile. You can change your username at any time.',
          },
          {
            'q': 'Does the AI Tutor need internet?',
            'a': 'Yes, the AI Tutor uses cloud AI models (Groq Whisper + Llama 3). You need an active connection to record and receive responses.',
          },
          {
            'q': 'Do lessons work offline?',
            'a': 'Yes. Levels and questions are loaded locally as a fallback. However, your progress will sync with the cloud when you regain connection.',
          },
          {
            'q': 'How are achievements calculated?',
            'a': '• 7 Day Streak: maintain 7 consecutive days.\n• First lesson: complete any lesson.\n• Coder Jr.: complete a Development level.\n• 5 English levels: complete 5 English levels.\n• Pro Empathy: complete a Soft Skills level.\n• Diamond League: accumulate 5000 XP.',
          },
          {
            'q': 'How do I reset my password?',
            'a': 'On the login screen, tap "Forgot your password?" and enter your email. You\'ll receive a reset link.',
          },
        ];
}
