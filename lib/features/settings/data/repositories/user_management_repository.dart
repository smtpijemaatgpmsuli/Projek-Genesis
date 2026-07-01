import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/managed_user.dart';
import '../../../authentication/domain/value_objects/user_role.dart';

abstract class UserManagementRepository {
  Future<List<ManagedUser>> fetchUsers();
  Future<void> inviteUser({required String email, required UserRole role});
  Future<void> updateUserRole({required String userId, required UserRole role});
  Future<void> toggleUserActive({required String userId, required bool isActive});
}

class SupabaseUserManagementRepository implements UserManagementRepository {
  SupabaseUserManagementRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ManagedUser>> fetchUsers() async {
    final data = await _client
        .from('profiles')
        .select('id, email, full_name, role, is_active')
        .order('full_name', ascending: true);

    return (data as List<dynamic>)
        .map((row) => ManagedUser.fromMap(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> inviteUser({
    required String email,
    required UserRole role,
  }) async {
    await _client.functions.invoke(
      'admin-create-user',
      body: {
        'email': email,
        'role': role.value,
      },
    );
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    await _client
        .from('profiles')
        .update({'role': role.value})
        .eq('id', userId);
  }

  @override
  Future<void> toggleUserActive({
    required String userId,
    required bool isActive,
  }) async {
    await _client
        .from('profiles')
        .update({'is_active': isActive})
        .eq('id', userId);
  }
}
