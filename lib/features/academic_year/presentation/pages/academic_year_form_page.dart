import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/controllers/academic_year_controller.dart';
import '../../domain/entities/academic_year.dart';

class AcademicYearFormPage extends ConsumerStatefulWidget {
  const AcademicYearFormPage({super.key, this.year});

  final AcademicYear? year;

  static const createPath = '/tahun-ajaran/tambah';
  static String editPath(String id) => '/tahun-ajaran/edit/$id';

  @override
  ConsumerState<AcademicYearFormPage> createState() =>
      _AcademicYearFormPageState();
}

class _AcademicYearFormPageState extends ConsumerState<AcademicYearFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  bool _isEdit = false;
  bool _initialized = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _startController = TextEditingController();
    _endController = TextEditingController();
    _isEdit = widget.year != null;

    if (widget.year != null) {
      _populate(widget.year!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _initialized) return;
        final routeState = GoRouterState.of(context);
        final id = routeState.pathParameters['id'];
        if (id != null && id.isNotEmpty) {
          _loadYear(id);
        }
      });
    }
  }

  void _populate(AcademicYear year) {
    _nameController.text = year.name;
    _startDate = year.startedAt;
    _endDate = year.endedAt;
    _startController.text = DateFormat('dd/MM/yyyy').format(year.startedAt);
    if (year.endedAt != null) {
      _endController.text = DateFormat('dd/MM/yyyy').format(year.endedAt!);
    }
    _isEdit = true;
    _initialized = true;
  }

  Future<void> _loadYear(String id) async {
    final repository = ref.read(academicYearRepositoryProvider);
    final year = await repository.getById(id);
    if (year != null && mounted) {
      setState(() => _populate(year));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller,
      bool isStart) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (picked != null && mounted) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai')),
      );
      return;
    }

    final year = AcademicYear(
      id: widget.year?.id ?? '',
      name: _nameController.text.trim(),
      isActive: widget.year?.isActive ?? false,
      startedAt: _startDate!,
      endedAt: _endDate,
    );

    final notifier = ref.read(academicYearFormProvider.notifier);
    final success =
        await (_isEdit ? notifier.update(year) : notifier.create(year));

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Tahun ajaran berhasil diperbarui'
              : 'Tahun ajaran berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(academicYearFormProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Tahun Ajaran' : 'Tambah Tahun Ajaran'),
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
                    Text('Data Tahun Ajaran',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tahun Ajaran',
                        hintText: 'Cth: 2026/2027',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _startController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      readOnly: true,
                      onTap: () => _pickDate(_startController, true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal mulai wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _endController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Selesai (opsional)',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      readOnly: true,
                      onTap: () => _pickDate(_endController, false),
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
                            : (_isEdit ? 'Simpan' : 'Tambah')),
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
