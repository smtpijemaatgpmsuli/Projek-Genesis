import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(Supabase.instance.client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier(this._repository) : super(null) {
    _repository.onAuthStateChanged((user) => state = user);
  }

  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) async {
    state = await _repository.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = null;
  }
}
