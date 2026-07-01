import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/assessment_entry.dart';

abstract class AssessmentRepository {
  Future<AssessmentEntry?> getAssessment(String studentId, String term);
  Future<void> saveAssessment(AssessmentEntry assessment);
}

class SupabaseAssessmentRepository implements AssessmentRepository {
  SupabaseAssessmentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AssessmentEntry?> getAssessment(String studentId, String term) async {
    final data = await _client
        .from('assessments')
        .select()
        .eq('student_id', studentId)
        .eq('term', term)
        .maybeSingle();

    if (data == null) return null;
    return AssessmentEntry.fromMap(data);
  }

  @override
  Future<void> saveAssessment(AssessmentEntry assessment) async {
    await _client.from('assessments').upsert(assessment.toMap());
  }
}
