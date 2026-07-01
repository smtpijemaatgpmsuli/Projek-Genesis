class AcademicYear {
  const AcademicYear({
    required this.id,
    required this.name,
    required this.isActive,
    required this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final bool isActive;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AcademicYear.fromMap(Map<String, dynamic> map) {
    return AcademicYear(
      id: map['id'] as String,
      name: map['name'] as String,
      isActive: map['is_active'] as bool,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        'is_active': isActive,
        'started_at': startedAt.toIso8601String(),
        if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
      };

  AcademicYear copyWith({
    String? id,
    String? name,
    bool? isActive,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademicYear(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
