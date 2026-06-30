import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository)..restoreSession();
});

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier(this._repository) : super(null);

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    state = await _repository.getCurrentUser();
    _repository.onAuthStateChanged((user) => state = user);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = await _repository.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = null;
  }
}
