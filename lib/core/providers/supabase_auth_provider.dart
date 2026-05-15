import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClient = Supabase.instance.client;

// Stream del estado de sesión
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabaseClient.auth.onAuthStateChange;
});

// Usuario actual (null si no hay sesión)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () => supabaseClient.auth.currentUser,
  );
});

// Si hay sesión activa
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

class AuthService {
  final _client = supabaseClient;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    // Crear perfil — si falla no rompemos el flujo de auth
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'username': username,
          'email': email,
          'total_xp': 0,
          'streak': 0,
          'lessons_completed': 0,
        });
      } catch (e) {
        // El perfil se puede crear luego en el primer login
        debugPrint('Profile insert deferred: $e');
      }
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    
    // Bug #6 fix: Asegurar que el perfil exista al iniciar sesión
    if (response.user != null) {
      try {
        final userId = response.user!.id;
        final username = response.user!.userMetadata?['username'] as String? ?? email.split('@').first;
        
        await _client.from('profiles').upsert({
          'id': userId,
          'username': username,
          'email': email,
          // No sobreescribimos XP ni racha si ya existen, upsert se encarga si la tabla está bien configurada
          // O podemos usar un select previo si preferimos ser cautelosos.
        }, onConflict: 'id');
      } catch (e) {
        debugPrint('Error garantizando perfil en login: $e');
      }
    }
    
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String? get currentUserId => _client.auth.currentUser?.id;
  String? get currentUsername =>
      _client.auth.currentUser?.userMetadata?['username'] as String?;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
