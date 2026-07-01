enum AttendanceStatus {
  present,
  absent,
  excused;

  String get value => name;

  static AttendanceStatus fromValue(String value) {
    return switch (value) {
      'present' => AttendanceStatus.present,
      'absent' => AttendanceStatus.absent,
      'excused' => AttendanceStatus.excused,
      _ => AttendanceStatus.absent,
    };
  }
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
  });

  final String id;
  final String sessionId;
  final String studentId;
  final AttendanceStatus status;

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      studentId: map['student_id'] as String,
      status: AttendanceStatus.fromValue(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'student_id': studentId,
        'status': status.value,
      };
}
