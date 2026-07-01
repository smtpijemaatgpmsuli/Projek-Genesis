import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/attendance_repository.dart';
import '../../domain/entities/student_brief.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return SupabaseAttendanceRepository(Supabase.instance.client);
});

/// Provider untuk daftar kelas aktif (digunakan di picker).
final classListForAttendanceProvider = FutureProvider<List<({String id, String name})>>((ref) async {
  final data = await Supabase.instance.client
      .from('classes')
      .select('id, name')
      .eq('is_active', true)
      .order('name');
  return (data as List)
      .map((e) => (id: e['id'] as String, name: e['name'] as String))
      .toList(growable: false);
});

class AttendanceState {
  const AttendanceState({
    this.students = const AsyncValue.data([]),
    this.loading = false,
    this.error,
  });

  final AsyncValue<List<StudentBrief>> students;
  final bool loading;
  final String? error;

  AttendanceState copyWith({
    AsyncValue<List<StudentBrief>>? students,
    bool? loading,
    String? error,
  }) {
    return AttendanceState(
      students: students ?? this.students,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AttendanceController extends StateNotifier<AttendanceState> {
  AttendanceController(this._repository) : super(const AttendanceState());

  final AttendanceRepository _repository;

  Future<void> loadStudents(String classId) async {
    state = state.copyWith(students: const AsyncValue.loading(), loading: true);
    final result = await AsyncValue.guard(
      () => _repository.getStudents(classId),
    );
    state = state.copyWith(students: result, loading: false);
  }
}

final attendanceStateProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceController(repository);
});
