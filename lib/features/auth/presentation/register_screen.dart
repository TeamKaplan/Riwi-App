import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../../core/providers/progress_provider.dart';

final _emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(authServiceProvider).signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        username: _usernameCtrl.text.trim(),
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
    if (msg.contains('already registered')) return 'Este email ya está registrado.';
    if (msg.contains('Password should')) return 'La contraseña debe tener al menos 6 caracteres.';
    if (msg.contains('network')) return 'Sin conexión. Verifica tu internet.';
    return msg;
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
                  Icon(Icons.person_add_rounded, size: 64, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Crear cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a la comunidad RIWI',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  ),
                  const SizedBox(height: 40),

                  // Username
                  TextFormField(
                    controller: _usernameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDeco(cs, 'Nombre de usuario', Icons.badge_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo requerido';
                      if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                      if (v.trim().length > 30) return 'Máximo 30 caracteres';
                      if (!RegExp(r'^[\w\-. ]+$').hasMatch(v.trim())) {
                        return 'Solo letras, números, guiones y puntos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    decoration: _inputDeco(cs, 'Contraseña', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: cs.onSurfaceVariant,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      if (v.length < 8) return 'Mínimo 8 caracteres';
                      if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Debe contener al menos una letra';
                      if (!RegExp(r'[0-9]').hasMatch(v)) return 'Debe contener al menos un número';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

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
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(color: Colors.red, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Botón registrar
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Ir a login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿Ya tienes cuenta?',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text('Ingresar',
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
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
