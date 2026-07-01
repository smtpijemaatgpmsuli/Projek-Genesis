import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/school_class.dart';

abstract class ClassRepository {
  Future<List<SchoolClass>> getAll({bool? activeOnly});
  Future<SchoolClass?> getById(String id);
  Future<SchoolClass> create(SchoolClass schoolClass);
  Future<SchoolClass> update(SchoolClass schoolClass);
  Future<void> delete(String id);
  Future<List<SchoolClass>> getByAcademicYear(String academicYearId);
}

class SupabaseClassRepository implements ClassRepository {
  SupabaseClassRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<SchoolClass>> getAll({bool? activeOnly}) async {
    var query = _client.from('classes').select('''
        *,
        academic_years!inner(name),
        students:students(count)
      ''');

    if (activeOnly == true) {
      query = query.eq('is_active', true);
    }

    final data = await query.order('name');

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      if (map['academic_years'] != null) {
        map['academic_year_name'] = (map['academic_years'] as Map)['name'];
        map.remove('academic_years');
      }
      if (map['students'] is List) {
        map['student_count'] = (map['students'] as List).length;
      } else if (map['students'] is Map) {
        map['student_count'] = (map['students'] as Map)['count'] as int? ?? 0;
      }
      map.remove('students');
      return SchoolClass.fromMap(map);
    }).toList(growable: false);
  }

  @override
  Future<SchoolClass?> getById(String id) async {
    final data = await _client
        .from('classes')
        .select('''
          *,
          academic_years!inner(name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;

    final map = Map<String, dynamic>.from(data as Map);
    if (map['academic_years'] != null) {
      map['academic_year_name'] = (map['academic_years'] as Map)['name'];
      map.remove('academic_years');
    }
    return SchoolClass.fromMap(map);
  }

  @override
  Future<SchoolClass> create(SchoolClass schoolClass) async {
    final data = await _client
        .from('classes')
        .insert(schoolClass.toMap())
        .select()
        .single();

    return SchoolClass.fromMap(data);
  }

  @override
  Future<SchoolClass> update(SchoolClass schoolClass) async {
    final data = await _client
        .from('classes')
        .update(schoolClass.toMap())
        .eq('id', schoolClass.id)
        .select()
        .single();

    return SchoolClass.fromMap(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client
        .from('classes')
        .update({'is_active': false})
        .eq('id', id);
  }

  @override
  Future<List<SchoolClass>> getByAcademicYear(String academicYearId) async {
    final data = await _client
        .from('classes')
        .select('''
          *,
          academic_years!inner(name)
        ''')
        .eq('academic_year_id', academicYearId)
        .eq('is_active', true)
        .order('name');

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      if (map['academic_years'] != null) {
        map['academic_year_name'] = (map['academic_years'] as Map)['name'];
        map.remove('academic_years');
      }
      return SchoolClass.fromMap(map);
    }).toList(growable: false);
  }
}
