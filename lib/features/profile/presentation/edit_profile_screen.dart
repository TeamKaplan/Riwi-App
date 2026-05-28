import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/supabase_auth_provider.dart';
import '../../../core/providers/locale_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _savingUsername = false;
  bool _savingPassword = false;
  bool _showNewPass     = false;
  bool _showConfirmPass = false;
  bool _hasNewPass      = false; // controla si el botón está habilitado

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authServiceProvider);
    _usernameCtrl = TextEditingController(text: auth.currentUsername ?? '');
    _newPassCtrl.addListener(() {
      final has = _newPassCtrl.text.isNotEmpty;
      if (has != _hasNewPass) setState(() => _hasNewPass = has);
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    final newName = _usernameCtrl.text.trim();
    if (newName.isEmpty) return;
    setState(() => _savingUsername = true);
    try {
      await ref.read(authServiceProvider).updateUsername(newName);
      if (mounted) _showSnack(_isSpanish ? '¡Nombre actualizado!' : 'Name updated!', success: true);
    } catch (e) {
      if (mounted) _showSnack(_isSpanish ? 'Error: $e' : 'Error: $e');
    } finally {
      if (mounted) setState(() => _savingUsername = false);
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final newPass = _newPassCtrl.text.trim();
    setState(() => _savingPassword = true);
    try {
      await ref.read(authServiceProvider).updatePassword(newPass);
      if (mounted) {
        _showSnack(_isSpanish ? '¡Contraseña actualizada!' : 'Password updated!', success: true);
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      }
    } catch (e) {
      if (mounted) _showSnack(_isSpanish ? 'Error: $e' : 'Error: $e');
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  bool get _isSpanish => ref.read(localeProvider).languageCode == 'es';

  @override
  Widget build(BuildContext context) {
    final isSpanish = ref.watch(localeProvider).languageCode == 'es';
    final cs = Theme.of(context).colorScheme;
    final auth = ref.read(authServiceProvider);

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
          isSpanish ? 'Editar Perfil' : 'Edit Profile',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ───────────────────────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: cs.primary,
                      child: const Icon(Icons.person, size: 52, color: Colors.white),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  auth.currentEmail ?? '',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ),

              const SizedBox(height: 32),

              // ── Sección: Nombre ───────────────────────────────────────
              _sectionTitle(isSpanish ? 'Información personal' : 'Personal info', cs),
              const SizedBox(height: 12),

              TextFormField(
                controller: _usernameCtrl,
                style: TextStyle(color: cs.onSurface),
                decoration: _inputDecoration(
                  cs,
                  label: isSpanish ? 'Nombre de usuario' : 'Username',
                  icon: Icons.person_outline,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (isSpanish ? 'Campo obligatorio' : 'Required field')
                    : null,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _savingUsername ? null : _saveUsername,
                  icon: _savingUsername
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check, size: 18),
                  label: Text(isSpanish ? 'Guardar nombre' : 'Save name'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 20),

              // ── Sección: Contraseña ───────────────────────────────────
              _sectionTitle(isSpanish ? 'Cambiar contraseña' : 'Change password', cs),
              const SizedBox(height: 12),

              TextFormField(
                controller: _newPassCtrl,
                obscureText: !_showNewPass,
                style: TextStyle(color: cs.onSurface),
                decoration: _inputDecoration(
                  cs,
                  label: isSpanish ? 'Nueva contraseña' : 'New password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPass ? Icons.visibility_off : Icons.visibility, size: 20, color: cs.onSurfaceVariant),
                    onPressed: () => setState(() => _showNewPass = !_showNewPass),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // opcional
                  if (v.length < 6) return isSpanish ? 'Mínimo 6 caracteres' : 'Minimum 6 characters';
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: !_showConfirmPass,
                style: TextStyle(color: cs.onSurface),
                decoration: _inputDecoration(
                  cs,
                  label: isSpanish ? 'Confirmar contraseña' : 'Confirm password',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPass ? Icons.visibility_off : Icons.visibility, size: 20, color: cs.onSurfaceVariant),
                    onPressed: () => setState(() => _showConfirmPass = !_showConfirmPass),
                  ),
                ),
                validator: (v) {
                  if (_newPassCtrl.text.isEmpty) return null;
                  if (v != _newPassCtrl.text) {
                    return isSpanish ? 'Las contraseñas no coinciden' : 'Passwords do not match';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _savingPassword || !_hasNewPass ? null : _savePassword,
                  icon: _savingPassword
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_reset, size: 18),
                  label: Text(isSpanish ? 'Cambiar contraseña' : 'Change password'),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme cs) => Text(
    title,
    style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
  );

  InputDecoration _inputDecoration(
    ColorScheme cs, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIcon: Icon(icon, color: cs.primary, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
      );
}
