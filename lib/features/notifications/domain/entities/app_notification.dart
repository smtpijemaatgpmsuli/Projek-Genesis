class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.sentAt,
    required this.read,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime sentAt;
  final bool read;

  AppNotification copyWith({
    bool? read,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      sentAt: sentAt,
      read: read ?? this.read,
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String? ?? '-',
      message: map['message'] as String? ?? '-',
      type: NotificationTypeX.fromString(map['type'] as String? ?? 'general'),
      sentAt: DateTime.parse(map['sent_at'] as String? ?? DateTime.now().toIso8601String()),
      read: map['read'] as bool? ?? false,
    );
  }
}

enum NotificationType {
  general,
  reportReady,
  attendanceReminder,
}

extension NotificationTypeX on NotificationType {
  String get value => switch (this) {
        NotificationType.general => 'general',
        NotificationType.reportReady => 'report_ready',
        NotificationType.attendanceReminder => 'attendance_reminder',
      };

  static NotificationType fromString(String value) => switch (value) {
        'report_ready' => NotificationType.reportReady,
        'attendance_reminder' => NotificationType.attendanceReminder,
        _ => NotificationType.general,
      };
}
