import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/parent_child.dart';

abstract class ParentRepository {
  Future<List<ParentChild>> getChildren(String parentId);
}

class SupabaseParentRepository implements ParentRepository {
  SupabaseParentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ParentChild>> getChildren(String parentId) async {
    // 1. Get all students linked to this parent
    final students = await _client
        .from('students')
        .select('id, full_name, class_id, classes!inner(name)')
        .eq('parent_id', parentId)
        .eq('is_active', true);

    if (students.isEmpty) return [];

    final result = <ParentChild>[];

    for (final s in students as List) {
      final map = Map<String, dynamic>.from(s as Map);
      final studentId = map['id'] as String;
      final className = (map['classes'] as Map)['name'] as String;

      // 2. Get attendance records with session dates
      final attendance = await _client
          .from('attendance_records')
          .select('status, attendance_sessions!inner(date)')
          .eq('student_id', studentId);

      int present = 0, absent = 0, excused = 0;
      for (final a in attendance as List) {
        final status = a['status'] as String;
        switch (status) {
          case 'present':
            present++;
            break;
          case 'absent':
            absent++;
            break;
          case 'excused':
            excused++;
            break;
        }
      }

      // 3. Get latest assessment
      final assessment = await _client
          .from('assessments')
          .select('spiritual, behavior, activity, term')
          .eq('student_id', studentId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      int spiritual = 0, behavior = 0, activity = 0;
      String? lastTerm;

      if (assessment != null) {
        final aMap = assessment as Map;
        spiritual = (aMap['spiritual'] as num?)?.toInt() ?? 0;
        behavior = (aMap['behavior'] as num?)?.toInt() ?? 0;
        activity = (aMap['activity'] as num?)?.toInt() ?? 0;
        lastTerm = aMap['term'] as String?;
      }

      final totalSessions = present + absent + excused;

      result.add(ParentChild(
        id: studentId,
        fullName: map['full_name'] as String,
        classId: map['class_id'] as String,
        className: className,
        presentCount: present,
        absentCount: absent,
        excusedCount: excused,
        totalSessions: totalSessions,
        spiritual: spiritual,
        behavior: behavior,
        activity: activity,
        lastAssessmentTerm: lastTerm,
      ));
    }

    return result;
  }
}
