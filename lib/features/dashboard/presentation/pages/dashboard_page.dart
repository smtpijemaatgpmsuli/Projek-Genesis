import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../authentication/application/providers/auth_state.dart';
import '../../../authentication/domain/value_objects/user_role.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../core/router/routes.dart';
import '../../application/controllers/dashboard_summary_controller.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return AdaptiveScaffold(
      mobile: _DashboardContent(
        userName: user?.displayName ?? user?.email ?? 'Pengguna',
        role: user?.role,
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: _DashboardContent(
            userName: user?.displayName ?? user?.email ?? 'Pengguna',
            role: user?.role,
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.userName, this.role});

  final String userName;
  final UserRole? role;

  bool get _canManageUsers =>
      role == UserRole.superAdmin || role == UserRole.admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (_canManageUsers)
            IconButton(
              tooltip: 'Kelola Pengguna',
              onPressed: () => context.go(Routes.userManagement),
              icon: const Icon(Icons.manage_accounts),
            ),
          IconButton(
            tooltip: 'Kehadiran',
            onPressed: () => context.go('/attendance'),
            icon: const Icon(Icons.fact_check_outlined),
          ),
          IconButton(
            tooltip: 'Penilaian',
            onPressed: () => context.go('/assessment'),
            icon: const Icon(Icons.rate_review_outlined),
          ),
          IconButton(
            tooltip: 'Rapor',
            onPressed: () => context.go('/report'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardSummaryProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Halo, $userName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              data: (summary) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatGrid(summary: summary),
                  const SizedBox(height: 24),
                  _AttendanceCard(summary: summary),
                  const SizedBox(height: 24),
                  _ActivityTimeline(highlights: summary.activityHighlights),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gagal memuat ringkasan dashboard'),
                  const SizedBox(height: 12),
                  Text(error.toString()),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(dashboardSummaryProvider.notifier).load(),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final crossAxisCount = isDesktop ? 4 : 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 3,
      children: [
        _StatCard(
          title: 'Kelas Aktif',
          value: summary.totalClasses.toString(),
          icon: Icons.class_,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Siswa Terdaftar',
          value: summary.totalStudents.toString(),
          icon: Icons.school,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Pengasuh',
          value: summary.totalCaregivers.toString(),
          icon: Icons.volunteer_activism,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Rapor Pending',
          value: summary.pendingReports.toString(),
          icon: Icons.pending_actions,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final rate = (summary.attendanceRate * 100).toStringAsFixed(1);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kehadiran Rata-rata',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: summary.attendanceRate,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    Text('$rate%'),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    'Rata-rata kehadiran minggu ini. Dorong pengasuh untuk memasukkan absensi secara konsisten.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.highlights});

  final List<ActivityHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Aktivitas Terbaru'),
              SizedBox(height: 12),
              Text('Belum ada aktivitas terbaru.'),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktivitas Terbaru',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final highlight in highlights)
              _ActivityItem(highlight: highlight),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.highlight});

  final ActivityHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today, size: 20),
      title: Text(highlight.className),
      subtitle: Text(highlight.summary),
      trailing: Text(DateFormat('dd MMM').format(highlight.date)),
    );
  }
}
