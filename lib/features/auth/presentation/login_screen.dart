import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../../core/providers/progress_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// Regex RFC 5322 simplificado para validación de email
final _emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authServiceProvider).signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      await ref.read(progressProvider.notifier).onLogin();
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(() => _error = _mapError(e.message));
    } catch (_) {
      setState(() => _error = 'Error de conexión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(String msg) {
    if (msg.contains('Invalid login')) return 'Email o contraseña incorrectos.';
    if (msg.contains('Email not confirmed')) return 'Confirma tu email antes de ingresar.';
    if (msg.contains('network')) return 'Sin conexión. Verifica tu internet.';
    return msg;
  }

  Future<void> _showForgotPassword(BuildContext ctx, ColorScheme cs) async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    String? dialogError;
    bool sent = false;

    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (!sent)
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: cs.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: dialogError,
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Enlace enviado! Revisa tu bandeja de entrada.',
                        style: TextStyle(color: cs.onSurface, fontSize: 13),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(sent ? 'Cerrar' : 'Cancelar', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            if (!sent)
              FilledButton(
                onPressed: () async {
                  final email = ctrl.text.trim();
                  if (!_emailRegex.hasMatch(email)) {
                    setDialogState(() => dialogError = 'Email inválido');
                    return;
                  }
                  try {
                    await Supabase.instance.client.auth.resetPasswordForEmail(email);
                    setDialogState(() { sent = true; dialogError = null; });
                  } catch (e) {
                    setDialogState(() => dialogError = 'Error al enviar. Intenta de nuevo.');
                  }
                },
                child: const Text('Enviar'),
              ),
          ],
        ),
      ),
    );
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / título
                  Icon(Icons.school_rounded, size: 72, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'RIWI App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aprende. Compite. Crece.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                  const SizedBox(height: 48),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDeco(cs, 'Email', Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo requerido';
                      if (!_emailRegex.hasMatch(v.trim())) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: _inputDeco(cs, 'Contraseña', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                            color: cs.onSurfaceVariant),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPassword(context, cs),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: cs.primary, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Error
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!,
                              style: const TextStyle(color: Colors.red, fontSize: 13))),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Botón ingresar
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : const Text('INGRESAR',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                  ),

                  const SizedBox(height: 16),

                  // Ir a registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes cuenta?',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text('Regístrate',
                            style: TextStyle(
                                color: cs.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(ColorScheme cs, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }
}
