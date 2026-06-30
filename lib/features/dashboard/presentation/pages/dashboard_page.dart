import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/application/providers/auth_state.dart';
import '../../../authentication/domain/value_objects/user_role.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../core/router/routes.dart';

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
          constraints: const BoxConstraints(maxWidth: 960),
          child: _DashboardContent(
            userName: user?.displayName ?? user?.email ?? 'Pengguna',
            role: user?.role,
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.userName, this.role});

  final String userName;
  final UserRole? role;

  bool get _canManageUsers =>
      role == UserRole.superAdmin || role == UserRole.admin;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $userName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                _DashboardCard(
                  title: 'Ringkasan Kelas',
                  description: 'Data kelas dan jadwal akan muncul di sini.',
                ),
                _DashboardCard(
                  title: 'Aktivitas Terbaru',
                  description: 'Progress dan aktivitas terbaru pengguna.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}
