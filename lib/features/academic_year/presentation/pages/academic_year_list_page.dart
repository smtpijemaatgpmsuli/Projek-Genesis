import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/controllers/academic_year_controller.dart';
import '../../domain/entities/academic_year.dart';

class AcademicYearListPage extends ConsumerStatefulWidget {
  const AcademicYearListPage({super.key});

  @override
  ConsumerState<AcademicYearListPage> createState() =>
      _AcademicYearListPageState();
}

class _AcademicYearListPageState extends ConsumerState<AcademicYearListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(academicYearListProvider.notifier).loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academicYearListProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahun Ajaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Tahun Ajaran',
            onPressed: () => context.push('/tahun-ajaran/tambah'),
          ),
        ],
      ),
      body: state.years.when(
        data: (years) {
          if (years.isEmpty) {
            return _buildEmpty(context);
          }
          if (isDesktop) {
            return _buildTable(context, years, state.activeYear);
          }
          return _buildList(context, years, state.activeYear);
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
                    ref.read(academicYearListProvider.notifier).loadAll(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada tahun ajaran',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Tambahkan tahun ajaran untuk memulai',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/tahun-ajaran/tambah'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tahun Ajaran'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      BuildContext context, List<AcademicYear> years, AcademicYear? active) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(academicYearListProvider.notifier).loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isActive = year.id == active?.id;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isActive
                    ? Colors.green.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.calendar_month,
                  color: isActive ? Colors.green : null,
                ),
              ),
              title: Row(
                children: [
                  Text(year.name),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Aktif',
                          style: TextStyle(fontSize: 11, color: Colors.green)),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                '${DateFormat('dd MMM yyyy').format(year.startedAt)}${year.endedAt != null ? ' - ${DateFormat('dd MMM yyyy').format(year.endedAt!)}' : ''}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'activate') {
                    ref
                        .read(academicYearListProvider.notifier)
                        .setActive(year.id);
                  } else if (value == 'edit') {
                    context.push('/tahun-ajaran/edit/${year.id}');
                  } else if (value == 'delete') {
                    _confirmDelete(context, year);
                  }
                },
                itemBuilder: (context) => [
                  if (!isActive)
                    const PopupMenuItem(
                      value: 'activate',
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Aktifkan'),
                        dense: true,
                      ),
                    ),
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

  Widget _buildTable(BuildContext context, List<AcademicYear> years,
      AcademicYear? active) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(academicYearListProvider.notifier).loadAll(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columns: [
            DataColumn(label: Text('Nama', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Mulai', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Selesai', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Status', style: theme.textTheme.titleSmall)),
            DataColumn(label: Text('Aksi', style: theme.textTheme.titleSmall)),
          ],
          rows: years.map((year) {
            final isActive = year.id == active?.id;
            return DataRow(cells: [
              DataCell(Text(year.name)),
              DataCell(Text(DateFormat('dd MMM yyyy').format(year.startedAt))),
              DataCell(Text(year.endedAt != null
                  ? DateFormat('dd MMM yyyy').format(year.endedAt!)
                  : '-')),
              DataCell(Chip(
                label: Text(isActive ? 'Aktif' : 'Nonaktif'),
                visualDensity: VisualDensity.compact,
                backgroundColor: isActive
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
              )),
              DataCell(Row(
                children: [
                  if (!isActive)
                    IconButton(
                      icon: const Icon(Icons.check_circle,
                          size: 20, color: Colors.green),
                      tooltip: 'Aktifkan',
                      onPressed: () => ref
                          .read(academicYearListProvider.notifier)
                          .setActive(year.id),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () =>
                        context.push('/tahun-ajaran/edit/${year.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, year),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AcademicYear year) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tahun Ajaran'),
        content: Text('Hapus ${year.name}? Tindakan ini permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(academicYearFormProvider.notifier).delete(year.id);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
