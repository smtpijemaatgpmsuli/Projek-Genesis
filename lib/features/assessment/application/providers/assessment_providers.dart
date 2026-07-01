import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/assessment_repository.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return SupabaseAssessmentRepository(Supabase.instance.client);
});
