import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';

/// Representasi status autentikasi.
///
/// - [AuthInitial]: session sedang dicek (loading).
/// - [AuthAuthenticated]: user sudah login.
/// - [AuthUnauthenticated]: user belum login / session habis.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository)..restoreSession();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    state = const AuthInitial();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthAuthenticated(user);
      } else {
        state = const AuthUnauthenticated();
      }
    } catch (_) {
      state = const AuthUnauthenticated();
    }
    _repository.onAuthStateChanged((user) {
      state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    final user = await _repository.signIn(email: email, password: password);
    state = AuthAuthenticated(user);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthUnauthenticated();
  }
}
