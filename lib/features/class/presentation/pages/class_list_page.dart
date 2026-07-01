import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/controllers/class_controller.dart';
import '../../domain/entities/school_class.dart';

class ClassListPage extends ConsumerStatefulWidget {
  const ClassListPage({super.key});

  @override
  ConsumerState<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends ConsumerState<ClassListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(classListProvider.notifier).loadAll(activeOnly: true));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classListProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Kelas',
            onPressed: () => context.push('/kelas/tambah'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kelas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(classListProvider.notifier)
                              .loadAll(activeOnly: true);
                          setState(() {});
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
                ref.read(classListProvider.notifier).search(query);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: state.classes.when(
              data: (classes) {
                if (classes.isEmpty) {
                  return _buildEmpty(context);
                }
                if (isDesktop) {
                  return _buildTable(context, classes);
                }
                return _buildList(context, classes);
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
                          ref.read(classListProvider.notifier).loadAll(),
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
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada data kelas',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Tambahkan kelas baru untuk memulai',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/kelas/tambah'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Kelas'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<SchoolClass> classes) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(classListProvider.notifier).loadAll(activeOnly: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final c = classes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(c.name),
              subtitle: Text(
                '${c.academicYearName ?? '-'}  •  ${c.studentCount ?? 0} siswa',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/kelas/edit/${c.id}');
                  } else if (value == 'delete') {
                    _confirmDelete(context, c);
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
                      title:
                          Text('Nonaktifkan', style: TextStyle(color: Colors.red)),
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

  Widget _buildTable(BuildContext context, List<SchoolClass> classes) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(classListProvider.notifier).loadAll(activeOnly: true),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columns: [
            DataColumn(label: Text('Nama Kelas', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Tahun Ajaran', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Siswa', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Status', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Aksi', style: theme.textTheme.titleSmall)),
          ],
          rows: classes.map((c) {
            return DataRow(cells: [
              DataCell(Text(c.name)),
              DataCell(Text(c.academicYearName ?? '-')),
              DataCell(Text('${c.studentCount ?? 0}')),
              DataCell(Chip(
                label: Text(c.isActive ? 'Aktif' : 'Nonaktif'),
                visualDensity: VisualDensity.compact,
                backgroundColor: c.isActive
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
              )),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => context.push('/kelas/edit/${c.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, c),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolClass c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nonaktifkan Kelas'),
        content: Text('Nonaktifkan kelas ${c.name}? Data tetap tersimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(classFormProvider.notifier).delete(c.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
  }
}
