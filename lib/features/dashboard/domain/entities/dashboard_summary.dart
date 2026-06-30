class DashboardSummary {
  const DashboardSummary({
    required this.totalClasses,
    required this.totalStudents,
    required this.totalCaregivers,
    required this.pendingReports,
    required this.attendanceRate,
    required this.activityHighlights,
  });

  final int totalClasses;
  final int totalStudents;
  final int totalCaregivers;
  final int pendingReports;
  final double attendanceRate;
  final List<ActivityHighlight> activityHighlights;

  factory DashboardSummary.fromMap(Map<String, dynamic> map) {
    return DashboardSummary(
      totalClasses: map['total_classes'] as int? ?? 0,
      totalStudents: map['total_students'] as int? ?? 0,
      totalCaregivers: map['total_caregivers'] as int? ?? 0,
      pendingReports: map['pending_reports'] as int? ?? 0,
      attendanceRate: (map['attendance_rate'] as num? ?? 0).toDouble(),
      activityHighlights: (map['activity_highlights'] as List<dynamic>? ?? [])
          .map((raw) => ActivityHighlight.fromMap(raw as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class ActivityHighlight {
  const ActivityHighlight({
    required this.date,
    required this.className,
    required this.summary,
  });

  final DateTime date;
  final String className;
  final String summary;

  factory ActivityHighlight.fromMap(Map<String, dynamic> map) {
    return ActivityHighlight(
      date: DateTime.parse(map['date'] as String? ?? DateTime.now().toIso8601String()),
      className: map['class_name'] as String? ?? '-',
      summary: map['summary'] as String? ?? '-',
    );
  }
}
