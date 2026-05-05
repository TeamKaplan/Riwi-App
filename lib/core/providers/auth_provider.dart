import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userName;
  final String? email;

  AuthState({this.isAuthenticated = false, this.userName, this.email});

  AuthState copyWith({bool? isAuthenticated, String? userName, String? email}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void loginWithGoogle() async {
    // Simulando inicio de sesión con Google
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      isAuthenticated: true,
      userName: 'Coder RIWI',
      email: 'coder@riwi.io',
    );
  }

  void logout() {
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
