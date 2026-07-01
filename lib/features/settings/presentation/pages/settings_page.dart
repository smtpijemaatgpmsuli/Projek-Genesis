import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genesis/features/authentication/application/providers/auth_state.dart';
import 'package:genesis/shared/widgets/adaptive_scaffold.dart';
import 'package:genesis/features/settings/application/providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final appName = ref.watch(appNameProvider);
    final appVersion = ref.watch(appVersionProvider);

    final user = switch (authState) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return AdaptiveScaffold(
      mobile: _SettingsContent(
        user: user,
        appName: appName,
        appVersion: appVersion,
        onSignOut: () => ref.read(authStateProvider.notifier).signOut(),
      ),
      desktop: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _SettingsContent(
            user: user,
            appName: appName,
            appVersion: appVersion,
            onSignOut: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.user,
    required this.appName,
    required this.appVersion,
    required this.onSignOut,
  });

  final dynamic user;
  final String appName;
  final String appVersion;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Text('Profil', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user?.displayName?.isNotEmpty == true
                          ? user.displayName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Pengguna',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.role.label ?? 'Unknown',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App Info Section
          Text('Tentang Aplikasi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Nama Aplikasi'),
                  trailing: Text(appName, style: theme.textTheme.bodyMedium),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text('Versi'),
                  trailing: Text(appVersion, style: theme.textTheme.bodyMedium),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Codename'),
                  trailing: const Text('Genesis', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Section
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'e-Raport Sekolah Minggu (Genesis) v',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}

