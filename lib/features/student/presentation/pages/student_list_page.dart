import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/controllers/student_controller.dart';
import '../../domain/entities/student.dart';

class StudentListPage extends ConsumerStatefulWidget {
  const StudentListPage({super.key});

  @override
  ConsumerState<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends ConsumerState<StudentListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(studentListProvider.notifier).loadAll(activeOnly: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentListProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Siswa',
            onPressed: () => context.push('/siswa/tambah'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama siswa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(studentListProvider.notifier)
                              .loadAll(activeOnly: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              onChanged: (query) {
                ref.read(studentListProvider.notifier).search(query);
                setState(() {});
              },
            ),
          ),

          // Content
          Expanded(
            child: state.students.when(
              data: (students) {
                if (students.isEmpty) {
                  return _buildEmpty(context);
                }

                if (isDesktop) {
                  return _buildTable(context, students);
                }
                return _buildList(context, students);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Gagal memuat data: $e'),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () =>
                          ref.read(studentListProvider.notifier).loadAll(),
                      child: const Text('Coba Lagi'),
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

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data siswa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan siswa baru untuk memulai',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/siswa/tambah'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Siswa'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Student> students) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(studentListProvider.notifier).loadAll(activeOnly: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(student.fullName),
              subtitle: Text(
                student.className ?? 'Kelas: -',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/siswa/edit/${student.id}');
                  } else if (value == 'delete') {
                    _confirmDelete(context, student);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Hapus', style: TextStyle(color: Colors.red)),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<Student> students) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(studentListProvider.notifier).loadAll(activeOnly: true),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          sortColumnIndex: 0,
          columns: [
            DataColumn(label: Text('Nama', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Kelas', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Status', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Aksi', style: theme.textTheme.titleSmall)),
          ],
          rows: students.map((student) {
            return DataRow(cells: [
              DataCell(Text(student.fullName)),
              DataCell(Text(student.className ?? '-')),
              DataCell( Chip(
                label: Text(student.isActive ? 'Aktif' : 'Nonaktif'),
                visualDensity: VisualDensity.compact,
                backgroundColor: student.isActive
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
              )),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () =>
                        context.push('/siswa/edit/${student.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, student),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content: Text(
            'Nonaktifkan ${student.fullName}? Data tetap tersimpan di database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(studentFormProvider.notifier).delete(student.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
  }
}
