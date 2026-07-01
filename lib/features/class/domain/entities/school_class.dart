class SchoolClass {
  const SchoolClass({
    required this.id,
    required this.name,
    this.description,
    required this.academicYearId,
    this.academicYearName,
    this.isActive = true,
    this.studentCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String academicYearId;
  final String? academicYearName;
  final bool isActive;
  final int? studentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SchoolClass.fromMap(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      academicYearId: map['academic_year_id'] as String,
      academicYearName: map['academic_year_name'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      studentCount: map['student_count'] as int?,
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
        if (description != null && description!.isNotEmpty)
          'description': description,
        'academic_year_id': academicYearId,
        'is_active': isActive,
      };

  SchoolClass copyWith({
    String? id,
    String? name,
    String? description,
    String? academicYearId,
    String? academicYearName,
    bool? isActive,
    int? studentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      academicYearId: academicYearId ?? this.academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      isActive: isActive ?? this.isActive,
      studentCount: studentCount ?? this.studentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
