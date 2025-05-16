import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// 🔁 Riverpod StateNotifierProvider for global access
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    // Set initial state to current user
    state = _authService.currentUser;

    // Listen to auth state changes (login/logout)
    _authService.authStateChanges.listen((user) {
      state = user;
    });
  }

  // 🔐 Register user with email & password
  Future<User?> register(String email, String password) async {
    final user = await _authService.registerCustomer(email, password);
    state = user;
    return user;
  }

  // 🔑 Login user
  Future<User?> login(String email, String password) async {
    final user = await _authService.signIn(email, password);
    state = user;
    return user;
  }

  // 🚪 Logout user
  Future<void> logout() async {
    await _authService.signOut();
    state = null;
  }
}
