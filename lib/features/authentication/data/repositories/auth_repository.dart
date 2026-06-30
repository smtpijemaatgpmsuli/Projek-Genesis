import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/value_objects/user_role.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  void onAuthStateChanged(void Function(AppUser?) callback);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: profile?['full_name'] as String?,
      role: _mapRole(profile?['role'] as String?),
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw AuthException('Invalid credentials');
    }

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: profile?['full_name'] as String?,
      role: _mapRole(profile?['role'] as String?),
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  void onAuthStateChanged(void Function(AppUser?) callback) {
    _client.auth.onAuthStateChange.listen((event) async {
      if (event.session == null) {
        callback(null);
      } else {
        callback(await getCurrentUser());
      }
    });
  }

  UserRole _mapRole(String? value) {
    return switch (value) {
      'super_admin' => UserRole.superAdmin,
      'admin' => UserRole.admin,
      'orang_tua' => UserRole.orangTua,
      _ => UserRole.pengasuh,
    };
  }
}
