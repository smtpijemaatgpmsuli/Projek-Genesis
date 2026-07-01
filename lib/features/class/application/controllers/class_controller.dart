import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/class_repository.dart';
import '../../domain/entities/school_class.dart';

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  return SupabaseClassRepository(Supabase.instance.client);
});

class ClassListState {
  const ClassListState({
    this.classes = const AsyncValue.data([]),
    this.searchQuery = '',
  });

  final AsyncValue<List<SchoolClass>> classes;
  final String searchQuery;

  ClassListState copyWith({
    AsyncValue<List<SchoolClass>>? classes,
    String? searchQuery,
  }) {
    return ClassListState(
      classes: classes ?? this.classes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ClassFormState {
  const ClassFormState({
    this.saving = false,
    this.error,
    this.success = false,
  });

  final bool saving;
  final String? error;
  final bool success;

  ClassFormState copyWith({
    bool? saving,
    String? error,
    bool? success,
  }) {
    return ClassFormState(
      saving: saving ?? this.saving,
      error: error,
      success: success ?? this.success,
    );
  }
}

final classListProvider =
    StateNotifierProvider<ClassListNotifier, ClassListState>((ref) {
  final repository = ref.watch(classRepositoryProvider);
  return ClassListNotifier(repository);
});

final classFormProvider =
    StateNotifierProvider<ClassFormNotifier, ClassFormState>((ref) {
  return ClassFormNotifier(ref);
});

class ClassListNotifier extends StateNotifier<ClassListState> {
  ClassListNotifier(this._repository) : super(const ClassListState());

  final ClassRepository _repository;

  Future<void> loadAll({bool? activeOnly}) async {
    state = state.copyWith(classes: const AsyncValue.loading());
    final result =
        await AsyncValue.guard(() => _repository.getAll(activeOnly: activeOnly));
    state = state.copyWith(classes: result);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    // Client-side filter karena data dikit
    final current = state.classes;
    if (current case AsyncData(:final value)) {
      if (query.isEmpty) {
        loadAll(activeOnly: true);
        return;
      }
      final filtered = value
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = state.copyWith(classes: AsyncValue.data(filtered));
    }
  }
}

class ClassFormNotifier extends StateNotifier<ClassFormState> {
  ClassFormNotifier(this._ref) : super(const ClassFormState());

  final Ref _ref;

  Future<bool> create(SchoolClass schoolClass) async {
    state = state.copyWith(saving: true, error: null, success: false);
    try {
      final repository = _ref.read(classRepositoryProvider);
      await repository.create(schoolClass);
      state = state.copyWith(saving: false, success: true);
      _ref.read(classListProvider.notifier).loadAll(activeOnly: true);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> update(SchoolClass schoolClass) async {
    state = state.copyWith(saving: true, error: null, success: false);
    try {
      final repository = _ref.read(classRepositoryProvider);
      await repository.update(schoolClass);
      state = state.copyWith(saving: false, success: true);
      _ref.read(classListProvider.notifier).loadAll(activeOnly: true);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final repository = _ref.read(classRepositoryProvider);
      await repository.delete(id);
      _ref.read(classListProvider.notifier).loadAll(activeOnly: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void reset() => state = const ClassFormState();
}
