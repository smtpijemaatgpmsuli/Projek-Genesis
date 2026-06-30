import '../../../assessment/domain/entities/assessment_entry.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../attendance/domain/entities/attendance_session.dart';
import '../../../attendance/domain/entities/student_brief.dart';

class ReportCard {
  const ReportCard({
    required this.student,
    required this.className,
    required this.term,
    required this.assessment,
    required this.attendanceSummary,
    required this.issuedAt,
    required this.signature,
  });

  final StudentBrief student;
  final String className;
  final String term;
  final AssessmentEntry assessment;
  final AttendanceSummary attendanceSummary;
  final DateTime issuedAt;
  final ReportSignature signature;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.totalSessions,
    required this.present,
    required this.absent,
    required this.excused,
  });

  final int totalSessions;
  final int present;
  final int absent;
  final int excused;

  factory AttendanceSummary.fromRecords(List<AttendanceRecord> records) {
    final present = records
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    final absent = records
        .where((record) => record.status == AttendanceStatus.absent)
        .length;
    final excused = records
        .where((record) => record.status == AttendanceStatus.excused)
        .length;

    final totalSessions = records.map((r) => r.sessionId).toSet().length;

    return AttendanceSummary(
      totalSessions: totalSessions,
      present: present,
      absent: absent,
      excused: excused,
    );
  }
}

class ReportSignature {
  const ReportSignature({
    required this.adminName,
    required this.caregiverName,
    required this.adminSignedAt,
    required this.caregiverSignedAt,
  });

  final String adminName;
  final String caregiverName;
  final DateTime? adminSignedAt;
  final DateTime? caregiverSignedAt;

  ReportSignature copyWith({
    String? adminName,
    String? caregiverName,
    DateTime? adminSignedAt,
    DateTime? caregiverSignedAt,
  }) {
    return ReportSignature(
      adminName: adminName ?? this.adminName,
      caregiverName: caregiverName ?? this.caregiverName,
      adminSignedAt: adminSignedAt ?? this.adminSignedAt,
      caregiverSignedAt: caregiverSignedAt ?? this.caregiverSignedAt,
    );
  }
}
