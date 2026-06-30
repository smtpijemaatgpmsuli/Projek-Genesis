import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary({required String role});
}

class SupabaseDashboardRepository implements DashboardRepository {
  SupabaseDashboardRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<DashboardSummary> fetchSummary({required String role}) async {
    final data = await _client.rpc('dashboard_summary', params: {
      'user_role': role,
    }) as Map<String, dynamic>;

    return DashboardSummary.fromMap(data);
  }
}
