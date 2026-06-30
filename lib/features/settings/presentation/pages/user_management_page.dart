import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/application/providers/auth_state.dart';
import '../../../authentication/domain/value_objects/user_role.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../shared/widgets/adaptive_scaffold.dart';
import '../../application/controllers/user_management_controller.dart';
import '../../domain/entities/managed_user.dart';
import '../../../../core/router/routes.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(userManagementControllerProvider);

    return AdaptiveScaffold(
      mobile: _UserManagementScaffold(usersState: usersState),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: _UserManagementScaffold(usersState: usersState),
        ),
      ),
    );
  }
}

class _UserManagementScaffold extends ConsumerWidget {
  const _UserManagementScaffold({required this.usersState});

  final AsyncValue<List<ManagedUser>> usersState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: usersState.when(
          data: (users) => _UsersTable(
            users: users,
            currentUserId: currentUser?.id,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Gagal memuat data pengguna'),
                const SizedBox(height: 12),
                Text(error.toString()),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(userManagementControllerProvider.notifier).loadUsers(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersTable extends ConsumerWidget {
  const _UsersTable({
    required this.users,
    required this.currentUserId,
  });

  final List<ManagedUser> users;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return const Center(child: Text('Belum ada pengguna terdaftar.'));
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (!isDesktop) {
      return ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserTile(
            user: user,
            isSelf: user.id == currentUserId,
          );
        },
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Nama')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Role')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Aksi')),
      ],
      rows: [
        for (final user in users)
          DataRow(
            cells: [
              DataCell(Text(user.fullName ?? '-')),
              DataCell(Text(user.email)),
              DataCell(_RoleDropdown(user: user, isSelf: user.id == currentUserId)),
              DataCell(_StatusChip(isActive: user.isActive)),
              DataCell(_ActionButtons(user: user, isSelf: user.id == currentUserId)),
            ],
          ),
      ],
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user, required this.isSelf});

  final ManagedUser user;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(user.fullName ?? user.email),
      subtitle: Text(user.email),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _StatusChip(isActive: user.isActive),
          const SizedBox(height: 8),
          _RoleDropdown(user: user, isSelf: isSelf),
        ],
      ),
    );
  }
}

class _RoleDropdown extends ConsumerStatefulWidget {
  const _RoleDropdown({required this.user, required this.isSelf});

  final ManagedUser user;
  final bool isSelf;

  @override
  ConsumerState<_RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends ConsumerState<_RoleDropdown> {
  late UserRole _selectedRole = widget.user.role;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserRole>(
      value: _selectedRole,
      onChanged: widget.isSelf
          ? null
          : (role) async {
              if (role == null) return;
              setState(() => _selectedRole = role);
              await ref
                  .read(userManagementControllerProvider.notifier)
                  .changeRole(userId: widget.user.id, role: role);
            },
      items: UserRole.values
          .map(
            (role) => DropdownMenuItem(
              value: role,
              child: Text(role.label),
            ),
          )
          .toList(),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(isActive ? 'Aktif' : 'Nonaktif'),
      backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.user, required this.isSelf});

  final ManagedUser user;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userManagementControllerProvider.notifier);
    final isActive = user.isActive;

    return Wrap(
      spacing: 8,
      children: [
        TextButton(
          onPressed: isSelf
              ? null
              : () => notifier.toggleActive(
                    userId: user.id,
                    isActive: !isActive,
                  ),
          child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
        ),
      ],
    );
  }
}
