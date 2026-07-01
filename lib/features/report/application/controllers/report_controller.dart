import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/report_repository.dart';
import '../../domain/entities/report_card.dart';
import '../../../attendance/domain/entities/student_brief.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return SupabaseReportRepository(Supabase.instance.client);
});

/// Provider to load students for the currently signed-in caregiver.
final reportStudentListProvider = FutureProvider<List<StudentBrief>>((ref) async {
  final client = Supabase.instance.client;
  // Get the user's assigned classes
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final classIds = await client
      .from('class_assignments')
      .select('class_id')
      .eq('profile_id', userId);

  if (classIds.isEmpty) return [];

  final ids = (classIds as List).map((e) => e['class_id'] as String).toList();

  final students = await client
      .from('students')
      .select('id, full_name')
      .inFilter('class_id', ids)
      .eq('is_active', true)
      .order('full_name');

  return (students as List)
      .map((e) => StudentBrief.fromMap(e as Map<String, dynamic>))
      .toList(growable: false);
});

class ReportState {
  const ReportState({
    required this.students,
    required this.currentTerm,
    this.selectedStudent,
    this.report = const AsyncValue.data(null),
    this.isSigning = false,
    this.error,
  });

  final List<StudentBrief> students;
  final String currentTerm;
  final StudentBrief? selectedStudent;
  final AsyncValue<ReportCard?> report;
  final bool isSigning;
  final String? error;

  ReportState copyWith({
    List<StudentBrief>? students,
    String? currentTerm,
    StudentBrief? selectedStudent,
    AsyncValue<ReportCard?>? report,
    bool? isSigning,
    String? error,
  }) {
    return ReportState(
      students: students ?? this.students,
      currentTerm: currentTerm ?? this.currentTerm,
      selectedStudent: selectedStudent ?? this.selectedStudent,
      report: report ?? this.report,
      isSigning: isSigning ?? this.isSigning,
      error: error,
    );
  }
}

class ReportController extends StateNotifier<ReportState> {
  ReportController(this._repository, List<StudentBrief> students)
      : super(ReportState(
          students: students,
          currentTerm: 'Semester 1',
        ));

  final ReportRepository _repository;

  Future<void> selectStudent(StudentBrief student) async {
    state = state.copyWith(selectedStudent: student, report: const AsyncValue.loading());

    final result = await AsyncValue.guard(() => _repository.fetchReport(
          studentId: student.id,
          term: state.currentTerm,
        ));

    state = state.copyWith(report: result);
  }

  void changeTerm(String term) {
    state = state.copyWith(currentTerm: term);
    final student = state.selectedStudent;
    if (student != null) {
      selectStudent(student);
    }
  }

  Future<void> signReport(String role) async {
    final report = state.report.value;
    if (report == null) return;

    state = state.copyWith(isSigning: true, error: null);
    try {
      await _repository.signReport(reportId: report.assessment.id, role: role);
      await selectStudent(report.student);
      state = state.copyWith(isSigning: false);
    } catch (error) {
      state = state.copyWith(isSigning: false, error: error.toString());
      rethrow;
    }
  }
}

final reportStateProvider = StateNotifierProvider.autoDispose<
    ReportController, ReportState>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  // Initial empty — students will be loaded async by reportStudentListProvider
  return ReportController(repository, []);
});
