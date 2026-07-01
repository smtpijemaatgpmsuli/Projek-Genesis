class StudentBrief {
  const StudentBrief({
    required this.id,
    required this.fullName,
  });

  final String id;
  final String fullName;

  factory StudentBrief.fromMap(Map<String, dynamic> map) {
    return StudentBrief(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
      };
}
