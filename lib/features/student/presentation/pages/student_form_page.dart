import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../application/controllers/student_controller.dart';
import '../../domain/entities/student.dart';

/// Minimal class brief untuk dropdown.
class _ClassBrief {
  const _ClassBrief({required this.id, required this.name});
  final String id;
  final String name;
}

final _classListProvider = FutureProvider<List<_ClassBrief>>((ref) async {
  final data = await Supabase.instance.client
      .from('classes')
      .select('id, name')
      .eq('is_active', true)
      .order('name');
  return (data as List)
      .map((e) => _ClassBrief(id: e['id'] as String, name: e['name'] as String))
      .toList(growable: false);
});

class StudentFormPage extends ConsumerStatefulWidget {
  const StudentFormPage({
    super.key,
    this.student,
  });

  final Student? student;

  static const createPath = '/siswa/tambah';
  static String editPath(String id) => '/siswa/edit/$id';

  /// For router — determine from key if edit mode.
  bool get isEdit => student != null;

  @override
  ConsumerState<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends ConsumerState<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _selectedClassId;
  bool _isEdit = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _isEdit = widget.student != null;

    if (widget.student != null) {
      _nameController.text = widget.student!.fullName;
      _selectedClassId = widget.student!.classId;
      _initialized = true;
    } else {
      // Check if this is edit mode via route params
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _initialized) return;
        final routeState = GoRouterState.of(context);
        final studentId = routeState.pathParameters['id'];
        if (studentId != null && studentId.isNotEmpty) {
          _loadStudent(studentId);
        }
      });
    }
  }

  Future<void> _loadStudent(String id) async {
    final repository = ref.read(studentRepositoryProvider);
    final student = await repository.getById(id);
    if (student != null && mounted) {
      _populateFromStudent(student);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Untuk route edit yang pake path parameter :id
  /// Dipanggil setelah student berhasil di-fetch.
  void _populateFromStudent(Student student) {
    if (_initialized) return;
    setState(() {
      _nameController.text = student.fullName;
      _selectedClassId = student.classId;
      _isEdit = true;
      _initialized = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null || _selectedClassId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kelas terlebih dahulu')),
      );
      return;
    }

    final student = Student(
      id: widget.student?.id ?? '',
      fullName: _nameController.text.trim(),
      classId: _selectedClassId!,
    );

    final notifier = ref.read(studentFormProvider.notifier);
    final success = await (_isEdit ? notifier.update(student) : notifier.create(student));

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Siswa berhasil diperbarui' : 'Siswa berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(studentFormProvider);
    final classes = ref.watch(_classListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Siswa' : 'Tambah Siswa'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Siswa',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap siswa',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                        onChanged: (v) => setState(() => _selectedClassId = v),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kelas wajib dipilih';
                          }
                          return null;
                        },
                      ),
                      loading: () => DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Kelas',
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: [],
                        onChanged: null,
                      ),
                      error: (e, _) => Text('Gagal memuat kelas: $e'),
                    ),
                    const SizedBox(height: 24),

                    if (formState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          formState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: formState.saving ? null : _submit,
                        icon: formState.saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_isEdit ? Icons.save : Icons.person_add),
                        label: Text(
                          formState.saving
                              ? 'Menyimpan...'
                              : (_isEdit
                                  ? 'Simpan Perubahan'
                                  : 'Tambah Siswa'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
