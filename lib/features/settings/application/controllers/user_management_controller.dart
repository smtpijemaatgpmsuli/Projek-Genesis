import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/user_management_repository.dart';
import '../../domain/entities/managed_user.dart';
import '../../../authentication/domain/value_objects/user_role.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  return SupabaseUserManagementRepository(Supabase.instance.client);
});

final userManagementControllerProvider = StateNotifierProvider.autoDispose<
    UserManagementController, AsyncValue<List<ManagedUser>>>((ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return UserManagementController(repository)..loadUsers();
});

final inviteUserControllerProvider =
    AutoDisposeStateNotifierProvider<InviteUserController, AsyncValue<void>>(
        (ref) {
  final repository = ref.watch(userManagementRepositoryProvider);
  return InviteUserController(repository);
});

class UserManagementController
    extends StateNotifier<AsyncValue<List<ManagedUser>>> {
  UserManagementController(this._repository)
      : super(const AsyncValue.loading());

  final UserManagementRepository _repository;

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchUsers);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repository.fetchUsers);
  }

  Future<void> changeRole({
    required String userId,
    required UserRole role,
  }) async {
    final previous = state;
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final user in current)
        if (user.id == userId) user.copyWith(role: role) else user,
    ]);
    try {
      await _repository.updateUserRole(userId: userId, role: role);
    } catch (error, _) {
      state = previous;
      rethrow;
    }
  }

  Future<void> toggleActive({
    required String userId,
    required bool isActive,
  }) async {
    final previous = state;
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final user in current)
        if (user.id == userId) user.copyWith(isActive: isActive) else user,
    ]);
    try {
      await _repository.toggleUserActive(userId: userId, isActive: isActive);
    } catch (error, _) {
      state = previous;
      rethrow;
    }
  }
}

class InviteUserController extends StateNotifier<AsyncValue<void>> {
  InviteUserController(this._repository) : super(const AsyncValue.data(null));

  final UserManagementRepository _repository;

  Future<void> invite({
    required String email,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.inviteUser(email: email, role: role),
    );
  }
}



