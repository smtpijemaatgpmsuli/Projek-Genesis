import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/academic_year.dart';

abstract class AcademicYearRepository {
  Future<List<AcademicYear>> getAll({bool? activeOnly});
  Future<AcademicYear?> getById(String id);
  Future<AcademicYear?> getActive();
  Future<AcademicYear> create(AcademicYear year);
  Future<AcademicYear> update(AcademicYear year);
  Future<void> delete(String id);
  Future<void> setActive(String id);
}

class SupabaseAcademicYearRepository implements AcademicYearRepository {
  SupabaseAcademicYearRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AcademicYear>> getAll({bool? activeOnly}) async {
    var query = _client.from('academic_years').select();

    if (activeOnly == true) {
      query = query.eq('is_active', true);
    }

    final data = await query.order('started_at', ascending: false);
    return (data as List)
        .map((e) => AcademicYear.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<AcademicYear?> getById(String id) async {
    final data = await _client
        .from('academic_years')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return AcademicYear.fromMap(data);
  }

  @override
  Future<AcademicYear?> getActive() async {
    final data = await _client
        .from('academic_years')
        .select()
        .eq('is_active', true)
        .maybeSingle();

    if (data == null) return null;
    return AcademicYear.fromMap(data);
  }

  @override
  Future<AcademicYear> create(AcademicYear year) async {
    final data = await _client
        .from('academic_years')
        .insert(year.toMap())
        .select()
        .single();

    return AcademicYear.fromMap(data);
  }

  @override
  Future<AcademicYear> update(AcademicYear year) async {
    final data = await _client
        .from('academic_years')
        .update(year.toMap())
        .eq('id', year.id)
        .select()
        .single();

    return AcademicYear.fromMap(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('academic_years').delete().eq('id', id);
  }

  @override
  Future<void> setActive(String id) async {
    // Deactivate all
    await _client
        .from('academic_years')
        .update({'is_active': false})
        .neq('id', 'none');

    // Activate target
    await _client
        .from('academic_years')
        .update({'is_active': true})
        .eq('id', id);
  }
}
