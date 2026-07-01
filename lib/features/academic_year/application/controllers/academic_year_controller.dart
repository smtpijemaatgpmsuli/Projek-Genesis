import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/academic_year_repository.dart';
import '../../domain/entities/academic_year.dart';

final academicYearRepositoryProvider = Provider<AcademicYearRepository>((ref) {
  return SupabaseAcademicYearRepository(Supabase.instance.client);
});

class AcademicYearListState {
  const AcademicYearListState({
    this.years = const AsyncValue.data([]),
    this.activeYear,
  });

  final AsyncValue<List<AcademicYear>> years;
  final AcademicYear? activeYear;

  AcademicYearListState copyWith({
    AsyncValue<List<AcademicYear>>? years,
    AcademicYear? activeYear,
  }) {
    return AcademicYearListState(
      years: years ?? this.years,
      activeYear: activeYear ?? this.activeYear,
    );
  }
}

class AcademicYearFormState {
  const AcademicYearFormState({
    this.saving = false,
    this.error,
    this.success = false,
  });

  final bool saving;
  final String? error;
  final bool success;

  AcademicYearFormState copyWith({
    bool? saving,
    String? error,
    bool? success,
  }) {
    return AcademicYearFormState(
      saving: saving ?? this.saving,
      error: error,
      success: success ?? this.success,
    );
  }
}

final academicYearListProvider =
    StateNotifierProvider<AcademicYearListNotifier, AcademicYearListState>(
        (ref) {
  final repository = ref.watch(academicYearRepositoryProvider);
  return AcademicYearListNotifier(repository);
});

final academicYearFormProvider =
    StateNotifierProvider<AcademicYearFormNotifier, AcademicYearFormState>(
        (ref) {
  return AcademicYearFormNotifier(ref);
});

/// Provider untuk dropdown class form — cached active years.
final activeYearsProvider = FutureProvider<List<AcademicYear>>((ref) async {
  final repository = ref.watch(academicYearRepositoryProvider);
  return repository.getAll(activeOnly: true);
});

class AcademicYearListNotifier extends StateNotifier<AcademicYearListState> {
  AcademicYearListNotifier(this._repository)
      : super(const AcademicYearListState());

  final AcademicYearRepository _repository;

  Future<void> loadAll() async {
    state = state.copyWith(years: const AsyncValue.loading());

    final result = await AsyncValue.guard(() => _repository.getAll());
    final active = result.maybeWhen(
      data: (list) => list.where((y) => y.isActive).firstOrNull,
      orElse: () => null,
    );

    state = state.copyWith(years: result, activeYear: active);
  }

  Future<void> setActive(String id) async {
    await _repository.setActive(id);
    loadAll();
    // Invalidate active years provider
  }
}

class AcademicYearFormNotifier extends StateNotifier<AcademicYearFormState> {
  AcademicYearFormNotifier(this._ref) : super(const AcademicYearFormState());

  final Ref _ref;

  Future<bool> create(AcademicYear year) async {
    state = state.copyWith(saving: true, error: null, success: false);
    try {
      final repository = _ref.read(academicYearRepositoryProvider);
      await repository.create(year);
      state = state.copyWith(saving: false, success: true);
      _ref.read(academicYearListProvider.notifier).loadAll();
      _ref.invalidate(activeYearsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> update(AcademicYear year) async {
    state = state.copyWith(saving: true, error: null, success: false);
    try {
      final repository = _ref.read(academicYearRepositoryProvider);
      await repository.update(year);
      state = state.copyWith(saving: false, success: true);
      _ref.read(academicYearListProvider.notifier).loadAll();
      _ref.invalidate(activeYearsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      final repository = _ref.read(academicYearRepositoryProvider);
      await repository.delete(id);
      _ref.read(academicYearListProvider.notifier).loadAll();
      _ref.invalidate(activeYearsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void reset() => state = const AcademicYearFormState();
}
