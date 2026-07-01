import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_session.dart';
import '../../domain/entities/student_brief.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceSession>> getSessions(String classId);
  Future<List<StudentBrief>> getStudents(String classId);
  Future<List<AttendanceRecord>> getRecords(String sessionId);
  Future<void> saveRecord(AttendanceRecord record);
  Future<void> saveRecords(List<AttendanceRecord> records);
}

class SupabaseAttendanceRepository implements AttendanceRepository {
  SupabaseAttendanceRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AttendanceSession>> getSessions(String classId) async {
    final data = await _client
        .from('attendance_sessions')
        .select()
        .eq('class_id', classId)
        .order('date', ascending: false);

    return (data as List)
        .map((e) => AttendanceSession.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<StudentBrief>> getStudents(String classId) async {
    final data = await _client
        .from('students')
        .select()
        .eq('class_id', classId)
        .eq('is_active', true);

    return (data as List)
        .map((e) => StudentBrief.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<AttendanceRecord>> getRecords(String sessionId) async {
    final data = await _client
        .from('attendance_records')
        .select()
        .eq('session_id', sessionId);

    return (data as List)
        .map((e) => AttendanceRecord.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> saveRecord(AttendanceRecord record) async {
    await _client.from('attendance_records').upsert(record.toMap());
  }

  @override
  Future<void> saveRecords(List<AttendanceRecord> records) async {
    await _client
        .from('attendance_records')
        .upsert(records.map((r) => r.toMap()).toList());
  }
}
