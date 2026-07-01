import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../academic_year/application/controllers/academic_year_controller.dart';
import '../../application/controllers/class_controller.dart';
import '../../domain/entities/school_class.dart';

class ClassFormPage extends ConsumerStatefulWidget {
  const ClassFormPage({super.key, this.schoolClass});

  final SchoolClass? schoolClass;

  @override
  ConsumerState<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends ConsumerState<ClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String? _selectedAcademicYearId;
  bool _isEdit = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _isEdit = widget.schoolClass != null;

    if (widget.schoolClass != null) {
      _nameController.text = widget.schoolClass!.name;
      _descController.text = widget.schoolClass!.description ?? '';
      _selectedAcademicYearId = widget.schoolClass!.academicYearId;
      _initialized = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _initialized) return;
        final routeState = GoRouterState.of(context);
        final classId = routeState.pathParameters['id'];
        if (classId != null && classId.isNotEmpty) {
          _loadClass(classId);
        }
      });
    }
  }

  Future<void> _loadClass(String id) async {
    final repository = ref.read(classRepositoryProvider);
    final c = await repository.getById(id);
    if (c != null && mounted) {
      setState(() {
        _nameController.text = c.name;
        _descController.text = c.description ?? '';
        _selectedAcademicYearId = c.academicYearId;
        _isEdit = true;
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final schoolClass = SchoolClass(
      id: widget.schoolClass?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      academicYearId: _selectedAcademicYearId ?? '',
    );

    final notifier = ref.read(classFormProvider.notifier);
    final success = await (_isEdit ? notifier.update(schoolClass) : notifier.create(schoolClass));

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Kelas berhasil diperbarui' : 'Kelas berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(classFormProvider);
    final years = ref.watch(activeYearsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kelas' : 'Tambah Kelas'),
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
                    Text('Data Kelas',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kelas',
                        hintText: 'Cth: Kelas Kecil, Kelas Besar',
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama kelas wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        hintText: 'Deskripsi singkat tentang kelas',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    years.when(
                      data: (data) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tahun Ajaran',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        initialValue: _selectedAcademicYearId,
                        items: data
                            .map((y) => DropdownMenuItem(
                                  value: y.id,
                                  child: Text(y.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedAcademicYearId = v),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tahun ajaran wajib dipilih';
                          }
                          return null;
                        },
                      ),
                      loading: () => DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Tahun Ajaran',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        items: [],
                        onChanged: null,
                      ),
                      error: (e, _) => Text('Gagal memuat tahun ajaran: $e'),
                    ),
                    const SizedBox(height: 24),

                    if (formState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(formState.error!,
                            style: const TextStyle(color: Colors.red)),
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
                            : Icon(_isEdit ? Icons.save : Icons.add),
                        label: Text(formState.saving
                            ? 'Menyimpan...'
                            : (_isEdit ? 'Simpan Perubahan' : 'Tambah Kelas')),
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
