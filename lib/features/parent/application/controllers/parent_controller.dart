import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/parent_repository.dart';
import '../../domain/entities/parent_child.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return SupabaseParentRepository(Supabase.instance.client);
});

final parentChildrenProvider = FutureProvider<List<ParentChild>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildren(userId);
});
