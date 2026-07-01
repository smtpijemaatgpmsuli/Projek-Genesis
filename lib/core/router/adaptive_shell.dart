import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/application/providers/auth_state.dart';
import '../../features/authentication/domain/value_objects/user_role.dart';
import 'shell_tabs.dart';

/// Breakpoints — sesuai [11_RESPONSIVE_DESIGN_GUIDELINES.md].
const double _desktopBreakpoint = 1024;

/// Shell layout adaptif.
///
/// - Mobile (< 1024): BottomNavigationBar
/// - Desktop (>= 1024): Sidebar NavigationRail
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final location = GoRouterState.of(context).matchedLocation;
    final authState = ref.watch(authStateProvider);

    final tabs = switch (authState) {
      AuthAuthenticated(:final user) => switch (user.role) {
          UserRole.pengasuh => caregiverTabs,
          UserRole.orangTua => parentTabs,
          _ => adminTabs,
        },
      _ => adminTabs,
    };

    final currentIndex = indexForLocation(location);

    if (width >= _desktopBreakpoint) {
      return _DesktopShell(
        tabs: tabs,
        currentIndex: currentIndex,
        child: child,
      );
    }

    return _MobileShell(
      tabs: tabs,
      currentIndex: currentIndex,
      child: child,
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.tabs,
    required this.currentIndex,
    required this.child,
  });

  final List<ShellTab> tabs;
  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex >= tabs.length ? 0 : currentIndex,
        onDestinationSelected: (index) {
          final location = locationForIndex(index);
          if (location != GoRouterState.of(context).matchedLocation) {
            context.go(location);
          }
        },
        destinations: tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.tabs,
    required this.currentIndex,
    required this.child,
  });

  final List<ShellTab> tabs;
  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex >= tabs.length ? 0 : currentIndex,
            onDestinationSelected: (index) {
              final location = locationForIndex(index);
              if (location != GoRouterState.of(context).matchedLocation) {
                context.go(location);
              }
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const Icon(Icons.auto_stories, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    'Genesis',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SignOutButton(),
            ),
            destinations: tabs
                .map((t) => NavigationRailDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.activeIcon),
                      label: Text(t.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Keluar',
      onPressed: () => ref.read(authStateProvider.notifier).signOut(),
    );
  }
}
