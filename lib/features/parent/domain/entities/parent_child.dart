class ParentChild {
  const ParentChild({
    required this.id,
    required this.fullName,
    required this.classId,
    required this.className,
    this.presentCount = 0,
    this.absentCount = 0,
    this.excusedCount = 0,
    this.totalSessions = 0,
    this.spiritual = 0,
    this.behavior = 0,
    this.activity = 0,
    this.lastAssessmentTerm,
  });

  final String id;
  final String fullName;
  final String classId;
  final String className;
  final int presentCount;
  final int absentCount;
  final int excusedCount;
  final int totalSessions;
  final int spiritual;
  final int behavior;
  final int activity;
  final String? lastAssessmentTerm;

  factory ParentChild.fromMap(Map<String, dynamic> map) {
    return ParentChild(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      classId: map['class_id'] as String,
      className: map['class_name'] as String? ?? '-',
      presentCount: (map['present_count'] as num?)?.toInt() ?? 0,
      absentCount: (map['absent_count'] as num?)?.toInt() ?? 0,
      excusedCount: (map['excused_count'] as num?)?.toInt() ?? 0,
      totalSessions: (map['total_sessions'] as num?)?.toInt() ?? 0,
      spiritual: (map['spiritual'] as num?)?.toInt() ?? 0,
      behavior: (map['behavior'] as num?)?.toInt() ?? 0,
      activity: (map['activity'] as num?)?.toInt() ?? 0,
      lastAssessmentTerm: map['last_assessment_term'] as String?,
    );
  }
}
