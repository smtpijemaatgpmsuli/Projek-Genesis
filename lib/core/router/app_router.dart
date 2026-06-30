import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/application/providers/auth_state.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/user_management_page.dart';
import 'guards/auth_guard.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = ref.read(authGuardProvider);

  return GoRouter(
    initialLocation: Routes.dashboard,
    redirect: authGuard.handleRedirect,
    refreshListenable: AuthRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: Routes.signIn,
        name: Routes.signIn,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SignInPage(),
        ),
      ),
      GoRoute(
        path: Routes.dashboard,
        name: Routes.dashboard,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardPage(),
        ),
      ),
      GoRoute(
        path: Routes.userManagement,
        name: Routes.userManagement,
        redirect: (context, state) {
          final user = ref.read(authStateProvider);
          if (user == null) {
            return Routes.signIn;
          }
          final role = user.role;
          final allowed = role == UserRole.superAdmin || role == UserRole.admin;
          if (!allowed) {
            return Routes.dashboard;
          }
          return null;
        },
        pageBuilder: (context, state) => const NoTransitionPage(
          child: UserManagementPage(),
        ),
      ),
    ],
  );
});

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
