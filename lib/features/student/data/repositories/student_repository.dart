import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getAll({String? classId, bool? activeOnly});
  Future<Student?> getById(String id);
  Future<Student> create(Student student);
  Future<Student> update(Student student);
  Future<void> delete(String id);
  Future<List<Student>> search(String query);
}

class SupabaseStudentRepository implements StudentRepository {
  SupabaseStudentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Student>> getAll({String? classId, bool? activeOnly}) async {
    var query = _client
        .from('students')
        .select('''
          *,
          classes!inner(name)
        ''');

    if (classId != null) {
      query = query.eq('class_id', classId);
    }

    if (activeOnly == true) {
      query = query.eq('is_active', true);
    }

    final data = await query.order('full_name');

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      // Flatten class name from joined query
      if (map['classes'] != null) {
        map['class_name'] = (map['classes'] as Map)['name'];
        map.remove('classes');
      }
      return Student.fromMap(map);
    }).toList(growable: false);
  }

  @override
  Future<Student?> getById(String id) async {
    final data = await _client
        .from('students')
        .select('''
          *,
          classes!inner(name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;

    final map = Map<String, dynamic>.from(data as Map);
    if (map['classes'] != null) {
      map['class_name'] = (map['classes'] as Map)['name'];
      map.remove('classes');
    }
    return Student.fromMap(map);
  }

  @override
  Future<Student> create(Student student) async {
    final data = await _client
        .from('students')
        .insert(student.toMap())
        .select()
        .single();

    return Student.fromMap(data);
  }

  @override
  Future<Student> update(Student student) async {
    final data = await _client
        .from('students')
        .update(student.toMap())
        .eq('id', student.id)
        .select()
        .single();

    return Student.fromMap(data);
  }

  @override
  Future<void> delete(String id) async {
    // Soft delete — set is_active = false
    await _client
        .from('students')
        .update({'is_active': false})
        .eq('id', id);
  }

  @override
  Future<List<Student>> search(String query) async {
    final data = await _client
        .from('students')
        .select('''
          *,
          classes!inner(name)
        ''')
        .ilike('full_name', '%$query%')
        .eq('is_active', true)
        .order('full_name');

    return (data as List).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      if (map['classes'] != null) {
        map['class_name'] = (map['classes'] as Map)['name'];
        map.remove('classes');
      }
      return Student.fromMap(map);
    }).toList(growable: false);
  }
}
