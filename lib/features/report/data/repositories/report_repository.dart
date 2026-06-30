import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../assessment/domain/entities/assessment_entry.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../attendance/domain/entities/attendance_session.dart';
import '../../../attendance/domain/entities/student_brief.dart';
import '../../domain/entities/report_card.dart';

abstract class ReportRepository {
  Future<ReportCard> fetchReport({
    required String studentId,
    required String term,
  });

  Future<void> signReport({
    required String reportId,
    required String role,
  });
}

class SupabaseReportRepository implements ReportRepository {
  SupabaseReportRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<ReportCard> fetchReport({
    required String studentId,
    required String term,
  }) async {
    final reportMap = await _client.rpc('generate_report_card', params: {
      'student_id': studentId,
      'term': term,
    }) as Map<String, dynamic>;

    final student = StudentBrief.fromMap(reportMap['student'] as Map<String, dynamic>);
    final assessment = AssessmentEntry.fromMap(reportMap['assessment'] as Map<String, dynamic>);

    final attendanceList = (reportMap['attendance'] as List<dynamic>)
        .map((raw) => AttendanceRecord.fromMap(raw as Map<String, dynamic>))
        .toList(growable: false);

    final signatureMap = reportMap['signature'] as Map<String, dynamic>?;
    final signature = ReportSignature(
      adminName: signatureMap?['admin_name'] as String? ?? '-',
      caregiverName: signatureMap?['caregiver_name'] as String? ?? '-',
      adminSignedAt: signatureMap?['admin_signed_at'] != null
          ? DateTime.parse(signatureMap!['admin_signed_at'] as String)
          : null,
      caregiverSignedAt: signatureMap?['caregiver_signed_at'] != null
          ? DateTime.parse(signatureMap!['caregiver_signed_at'] as String)
          : null,
    );

    return ReportCard(
      student: student,
      className: reportMap['class_name'] as String? ?? '-',
      term: term,
      assessment: assessment,
      attendanceSummary: AttendanceSummary.fromRecords(attendanceList),
      issuedAt: DateTime.parse(reportMap['issued_at'] as String? ?? DateTime.now().toIso8601String()),
      signature: signature,
    );
  }

  @override
  Future<void> signReport({
    required String reportId,
    required String role,
  }) async {
    await _client.rpc('sign_report_card', params: {
      'report_id': reportId,
      'role': role,
    });
  }
}
