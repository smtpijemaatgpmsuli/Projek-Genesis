class Student {
  const Student({
    required this.id,
    required this.fullName,
    required this.classId,
    this.parentId,
    this.className,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String fullName;
  final String classId;
  final String? parentId;
  final String? className;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      classId: map['class_id'] as String,
      parentId: map['parent_id'] as String?,
      className: map['class_name'] as String?,
      isActive: map['is_active'] as bool? ?? true,
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
        'full_name': fullName,
        'class_id': classId,
        if (parentId != null) 'parent_id': parentId,
        'is_active': isActive,
      };

  Student copyWith({
    String? id,
    String? fullName,
    String? classId,
    String? parentId,
    String? className,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      classId: classId ?? this.classId,
      parentId: parentId ?? this.parentId,
      className: className ?? this.className,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
