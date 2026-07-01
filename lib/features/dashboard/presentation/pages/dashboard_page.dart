import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis/core/router/routes.dart';
import 'package:genesis/shared/widgets/adaptive_scaffold.dart';

import '../../../authentication/application/providers/auth_state.dart';
import '../../../authentication/domain/value_objects/user_role.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    final (userName, role) = switch (authState) {
      AuthAuthenticated(:final user) => (
          user.displayName ?? user.email,
          user.role,
        ),
      _ => ('Pengguna', UserRole.pengasuh),
    };

    final menuItems = _buildMenuItems(context, role);

    return AdaptiveScaffold(
      mobile: _DashboardLayout(
        userName: userName,
        roleLabel: role.label,
        menuItems: menuItems,
        onSignOut: () => ref.read(authStateProvider.notifier).signOut(),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: _DashboardLayout(
            userName: userName,
            roleLabel: role.label,
            menuItems: menuItems,
            onSignOut: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ),
      ),
    );
  }

  List<_MenuItem> _buildMenuItems(BuildContext context, UserRole role) {
    final allItems = <_MenuItem>[
      _MenuItem(
        icon: Icons.people,
        label: 'Kelas',
        description: 'Kelola kelas dan jadwal',
        route: Routes.classes,
        roles: {UserRole.superAdmin, UserRole.admin, UserRole.pengasuh},
      ),
      _MenuItem(
        icon: Icons.school,
        label: 'Siswa',
        description: 'Data siswa Sekolah Minggu',
        route: Routes.students,
        roles: {UserRole.superAdmin, UserRole.admin, UserRole.pengasuh},
      ),
      _MenuItem(
        icon: Icons.calendar_today,
        label: 'Absensi',
        description: 'Catat kehadiran',
        route: Routes.absensi,
        roles: {UserRole.pengasuh},
      ),
      _MenuItem(
        icon: Icons.grading,
        label: 'Penilaian',
        description: 'Input nilai dan perkembangan',
        route: Routes.penilaian,
        roles: {UserRole.pengasuh},
      ),
      _MenuItem(
        icon: Icons.assignment,
        label: 'Rapor Digital',
        description: 'Lihat dan cetak rapor',
        route: Routes.report,
        roles: {UserRole.superAdmin, UserRole.admin, UserRole.pengasuh, UserRole.orangTua},
      ),
      _MenuItem(
        icon: Icons.calendar_month,
        label: 'Tahun Ajaran',
        description: 'Kelola tahun ajaran',
        route: Routes.academicYears,
        roles: {UserRole.superAdmin},
      ),
      _MenuItem(
        icon: Icons.person,
        label: 'Profil',
        description: 'Data orang tua dan anak',
        route: Routes.profil,
        roles: {UserRole.orangTua},
      ),
    ];

    return allItems.where((item) => item.roles.contains(role)).toList();
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
    required this.roles,
  });

  final IconData icon;
  final String label;
  final String description;
  final String route;
  final Set<UserRole> roles;
}

class _DashboardLayout extends StatelessWidget {
  const _DashboardLayout({
    required this.userName,
    required this.roleLabel,
    required this.menuItems,
    required this.onSignOut,
  });

  final String userName;
  final String roleLabel;
  final List<_MenuItem> menuItems;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: onSignOut,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil card
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $userName',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            roleLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu grid
          Text(
            'Menu Utama',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(item.route),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 36, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
