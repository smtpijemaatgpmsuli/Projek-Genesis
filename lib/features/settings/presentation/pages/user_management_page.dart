import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:genesis/features/authentication/application/providers/auth_state.dart';
import 'package:genesis/features/authentication/domain/value_objects/user_role.dart';
import 'package:genesis/shared/widgets/adaptive_scaffold.dart';
import '../../application/controllers/user_management_controller.dart';
import '../../domain/entities/managed_user.dart';
import 'package:genesis/core/router/routes.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(userManagementControllerProvider);

    ref.listen(inviteUserControllerProvider, (previous, next) {
      if (next.isLoading) return;
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Undangan pengguna dikirim.')),
          );
          ref.read(userManagementControllerProvider.notifier).refresh();
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengundang: $error')),
          );
        },
      );
    });

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
    final authState = ref.watch(authStateProvider);
  final currentUserId = switch (authState) {
    AuthAuthenticated(:final user) => user.id,
    _ => null,
  };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.dashboard),
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah Pengguna',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const _InviteUserDialog(),
            ),
            icon: const Icon(Icons.person_add_alt),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: usersState.when(
          data: (users) => _UsersTable(
            users: users,
            currentUserId: currentUserId,
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
      columnSpacing: 16,
      headingRowHeight: 48,
      dataRowMinHeight: 56,
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
          const SizedBox(height: 8),
          _ActionButtons(user: user, isSelf: isSelf),
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
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserRole>(
      value: _selectedRole,
      onChanged: widget.isSelf || _saving
          ? null
          : (role) async {
              if (role == null) return;
              setState(() {
                _selectedRole = role;
                _saving = true;
              });
              try {
                await ref
                    .read(userManagementControllerProvider.notifier)
                    .changeRole(userId: widget.user.id, role: role);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Role ${widget.user.email} diperbarui menjadi ${role.label}'),
                  ),
                );
              } catch (error) {
                setState(() => _selectedRole = widget.user.role);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memperbarui role: $error')),
                );
              } finally {
                if (mounted) {
                  setState(() => _saving = false);
                }
              }
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

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({required this.user, required this.isSelf});

  final ManagedUser user;
  final bool isSelf;

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(userManagementControllerProvider.notifier);
    final isActive = widget.user.isActive;

    return Wrap(
      spacing: 8,
      children: [
        TextButton(
          onPressed: widget.isSelf || _processing
              ? null
              : () async {
                  setState(() => _processing = true);
                  try {
                    await notifier.toggleActive(
                      userId: widget.user.id,
                      isActive: !isActive,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(!isActive
                            ? 'Pengguna diaktifkan.'
                            : 'Pengguna dinonaktifkan.'),
                      ),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal memperbarui status: $error')),
                    );
                  } finally {
                    if (mounted) setState(() => _processing = false);
                  }
                },
          child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
        ),
      ],
    );
  }
}

class _InviteUserDialog extends ConsumerStatefulWidget {
  const _InviteUserDialog();

  @override
  ConsumerState<_InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends ConsumerState<_InviteUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.pengasuh;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteUserControllerProvider);
    final isLoading = inviteState.isLoading;

    return AlertDialog(
      title: const Text('Undang Pengguna Baru'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                onChanged: isLoading ? null : (role) => setState(() => _selectedRole = role ?? _selectedRole),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  await ref
                      .read(inviteUserControllerProvider.notifier)
                      .invite(
                        email: _emailController.text.trim(),
                        role: _selectedRole,
                      );
                  if (mounted) Navigator.of(context).pop();
                },
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Kirim Undangan'),
        ),
      ],
    );
  }
}



