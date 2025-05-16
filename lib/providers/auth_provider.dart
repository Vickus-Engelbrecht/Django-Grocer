import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    // Initialize with current user
    state = _authService.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = await _authService.signIn(email, password);
  }

  Future<void> registerCustomer(String email, String password) async {
    state = await _authService.registerCustomer(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }
}
