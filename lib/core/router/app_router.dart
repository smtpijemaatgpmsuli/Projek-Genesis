import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
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
    ],
  );
});

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
