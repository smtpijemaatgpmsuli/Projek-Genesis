import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/student_repository.dart';
import '../../domain/entities/student.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return SupabaseStudentRepository(Supabase.instance.client);
});

/// State daftar siswa.
class StudentListState {
  const StudentListState({
    this.students = const AsyncValue.data([]),
    this.searchQuery = '',
  });

  final AsyncValue<List<Student>> students;
  final String searchQuery;

  StudentListState copyWith({
    AsyncValue<List<Student>>? students,
    String? searchQuery,
  }) {
    return StudentListState(
      students: students ?? this.students,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// State form siswa.
class StudentFormState {
  const StudentFormState({
    this.saving = false,
    this.error,
    this.success = false,
  });

  final bool saving;
  final String? error;
  final bool success;

  StudentFormState copyWith({
    bool? saving,
    String? error,
    bool? success,
  }) {
    return StudentFormState(
      saving: saving ?? this.saving,
      error: error,
      success: success ?? this.success,
    );
  }
}

final studentListProvider =
    StateNotifierProvider<StudentListNotifier, StudentListState>((ref) {
  final repository = ref.watch(studentRepositoryProvider);
  return StudentListNotifier(repository);
});

final studentFormProvider =
    StateNotifierProvider<StudentFormNotifier, StudentFormState>((ref) {
  return StudentFormNotifier(ref);
});

class StudentListNotifier extends StateNotifier<StudentListState> {
  StudentListNotifier(this._repository) : super(const StudentListState());

  final StudentRepository _repository;

  Future<void> loadAll({String? classId, bool? activeOnly}) async {
    state = state.copyWith(
      students: const AsyncValue.loading(),
    );

    final result = await AsyncValue.guard(
      () => _repository.getAll(classId: classId, activeOnly: activeOnly),
    );

    state = state.copyWith(students: result);
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);

    if (query.isEmpty) {
      loadAll(activeOnly: true);
      return;
    }

    state = state.copyWith(students: const AsyncValue.loading());
    final result = await AsyncValue.guard(
      () => _repository.search(query),
    );
    state = state.copyWith(students: result);
  }
}

class StudentFormNotifier extends StateNotifier<StudentFormState> {
  StudentFormNotifier(this._ref) : super(const StudentFormState());

  final Ref _ref;

  Future<bool> create(Student student) async {
    state = state.copyWith(saving: true, error: null, success: false);

    try {
      final repository = _ref.read(studentRepositoryProvider);
      await repository.create(student);
      state = state.copyWith(saving: false, success: true);
      // Refresh list
      _ref.read(studentListProvider.notifier).loadAll(activeOnly: true);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> update(Student student) async {
    state = state.copyWith(saving: true, error: null, success: false);

    try {
      final repository = _ref.read(studentRepositoryProvider);
      await repository.update(student);
      state = state.copyWith(saving: false, success: true);
      _ref.read(studentListProvider.notifier).loadAll(activeOnly: true);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final repository = _ref.read(studentRepositoryProvider);
      await repository.delete(id);
      _ref.read(studentListProvider.notifier).loadAll(activeOnly: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const StudentFormState();
  }
}
