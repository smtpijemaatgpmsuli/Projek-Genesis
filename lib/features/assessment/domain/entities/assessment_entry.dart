class AssessmentEntry {
  const AssessmentEntry({
    required this.id,
    required this.spiritual,
    required this.behavior,
    required this.activity,
    this.notes = '',
  });

  final String id;
  final int spiritual;
  final int behavior;
  final int activity;
  final String notes;

  factory AssessmentEntry.fromMap(Map<String, dynamic> map) {
    return AssessmentEntry(
      id: map['id'] as String,
      spiritual: (map['spiritual'] as num).toInt(),
      behavior: (map['behavior'] as num).toInt(),
      activity: (map['activity'] as num).toInt(),
      notes: (map['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'spiritual': spiritual,
        'behavior': behavior,
        'activity': activity,
        'notes': notes,
      };
}
