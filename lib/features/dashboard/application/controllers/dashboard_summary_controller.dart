import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../authentication/application/providers/auth_state.dart';
import '../../../authentication/domain/value_objects/user_role.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return SupabaseDashboardRepository(Supabase.instance.client);
});

final dashboardSummaryProvider = StateNotifierProvider.autoDispose<
    DashboardSummaryController, AsyncValue<DashboardSummary>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final role = switch (authState) {
    AuthAuthenticated(:final user) => user.role.value,
    _ => 'pengasuh',
  };
  return DashboardSummaryController(repository, role)
    ..load();
});

class DashboardSummaryController
    extends StateNotifier<AsyncValue<DashboardSummary>> {
  DashboardSummaryController(this._repository, this._role)
      : super(const AsyncValue.loading());

  final DashboardRepository _repository;
  final String _role;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.fetchSummary(role: _role),
    );
  }
}
