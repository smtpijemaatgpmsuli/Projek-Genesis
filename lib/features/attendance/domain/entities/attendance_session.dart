class AttendanceSession {
  const AttendanceSession({
    required this.id,
    required this.classId,
    required this.date,
    this.topic,
  });

  final String id;
  final String classId;
  final DateTime date;
  final String? topic;

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      id: map['id'] as String,
      classId: map['class_id'] as String,
      date: DateTime.parse(map['date'] as String),
      topic: map['topic'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'class_id': classId,
        'date': date.toIso8601String(),
        if (topic != null) 'topic': topic,
      };
}
