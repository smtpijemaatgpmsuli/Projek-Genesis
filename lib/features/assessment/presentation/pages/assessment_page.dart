import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/assessment_repository.dart';
import '../../domain/entities/assessment_entry.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return SupabaseAssessmentRepository(Supabase.instance.client);
});

/// Provider untuk daftar kelas aktif.
final _classListProvider = FutureProvider<List<({String id, String name})>>((ref) async {
  final data = await Supabase.instance.client
      .from('classes')
      .select('id, name')
      .eq('is_active', true)
      .order('name');
  return (data as List)
      .map((e) => (id: e['id'] as String, name: e['name'] as String))
      .toList(growable: false);
});

/// Provider untuk siswa dalam satu kelas.
final _studentsByClassProvider = FutureProvider.family<List<({String id, String fullName})>, String>((ref, classId) async {
  final data = await Supabase.instance.client
      .from('students')
      .select('id, full_name')
      .eq('class_id', classId)
      .eq('is_active', true)
      .order('full_name');
  return (data as List)
      .map((e) => (id: e['id'] as String, fullName: e['full_name'] as String))
      .toList(growable: false);
});

final _selectedTermProvider = StateProvider<String>((ref) => 'Semester 1');

class AssessmentPage extends ConsumerStatefulWidget {
  const AssessmentPage({super.key});

  @override
  ConsumerState<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends ConsumerState<AssessmentPage> {
  String? _selectedClassId;
  String? _selectedStudentId;
  int _spiritual = 0;
  int _behavior = 0;
  int _activity = 0;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _selectStudent(String studentId) {
    setState(() {
      _selectedStudentId = studentId;
      _spiritual = 0;
      _behavior = 0;
      _activity = 0;
      _notesController.clear();
    });
    _loadAssessment(studentId);
  }

  Future<void> _loadAssessment(String studentId) async {
    final term = ref.read(_selectedTermProvider);
    final repo = ref.read(assessmentRepositoryProvider);
    final result = await repo.getAssessment(studentId, term);
    if (result != null && mounted && _selectedStudentId == studentId) {
      setState(() {
        _spiritual = result.spiritual;
        _behavior = result.behavior;
        _activity = result.activity;
        _notesController.text = result.notes;
      });
    }
  }

  List<Widget> _buildStudentSelector() {
    if (_selectedClassId == null) return [];
    final students = ref.watch(_studentsByClassProvider(_selectedClassId!));
    return [
      const SizedBox(height: 16),
      ...students.when(
        data: (data) => [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Siswa',
              prefixIcon: Icon(Icons.person),
            ),
            initialValue: _selectedStudentId,
            items: data
                .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.fullName),
                    ))
                .toList(),
            onChanged: (id) {
              if (id != null) _selectStudent(id);
            },
          ),
        ],
        loading: () => [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Siswa', prefixIcon: Icon(Icons.person)),
            items: [],
            onChanged: null,
          ),
        ],
        error: (e, _) => [
          Text('Gagal memuat siswa: $e'),
        ],
      ),
    ];
  }

  Future<void> _save() async {
    if (_selectedStudentId == null) return;

    final term = ref.read(_selectedTermProvider);
    final repo = ref.read(assessmentRepositoryProvider);
    final assessment = AssessmentEntry(
      id: '${_selectedStudentId}_$term',
      spiritual: _spiritual,
      behavior: _behavior,
      activity: _activity,
      notes: _notesController.text,
    );

    await repo.saveAssessment(assessment);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penilaian berhasil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final term = ref.watch(_selectedTermProvider);
    final classes = ref.watch(_classListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Penilaian')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Input Nilai', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          // Step 1: Pilih kelas
          classes.when(
            data: (data) => DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kelas',
                prefixIcon: Icon(Icons.school),
              ),
              initialValue: _selectedClassId,
              items: data
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (id) {
                if (id != null) {
                  setState(() {
                    _selectedClassId = id;
                    _selectedStudentId = null;
                  });
                  ref.invalidate(_studentsByClassProvider(id));
                }
              },
            ),
            loading: () => DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Kelas', prefixIcon: Icon(Icons.school)),
              items: [],
              onChanged: null,
            ),
            error: (e, _) => Text('Gagal memuat kelas: $e'),
          ),
          const SizedBox(height: 16),

          // Step 2: Pilih siswa
          ..._buildStudentSelector(),

          // Step 3: Pilih periode
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Periode',
              prefixIcon: Icon(Icons.calendar_month),
            ),
            initialValue: term,
            items: const ['Semester 1', 'Semester 2']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(_selectedTermProvider.notifier).state = v;
                if (_selectedStudentId != null) {
                  _loadAssessment(_selectedStudentId!);
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // Step 4: Form nilai
          if (_selectedStudentId != null) ...[
            _ScoreSlider(
              label: 'Spiritual',
              value: _spiritual,
              onChanged: (v) => setState(() => _spiritual = v),
            ),
            _ScoreSlider(
              label: 'Perilaku',
              value: _behavior,
              onChanged: (v) => setState(() => _behavior = v),
            ),
            _ScoreSlider(
              label: 'Aktivitas',
              value: _activity,
              onChanged: (v) => setState(() => _activity = v),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan Pengasuh',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Penilaian'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreSlider extends StatelessWidget {
  const _ScoreSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text('$value/100', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: value.toString(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
