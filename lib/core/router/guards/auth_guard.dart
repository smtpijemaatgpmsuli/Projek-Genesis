import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/authentication/application/providers/auth_state.dart';
import '../routes.dart';

final authGuardProvider = Provider<AuthGuard>((ref) => AuthGuard(ref));

class AuthGuard {
  AuthGuard(this.ref);

  final Ref ref;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    final session = ref.read(authStateProvider);

    final loggingIn = state.matchedLocation == Routes.signIn;
    if (session == null) {
      return loggingIn ? null : Routes.signIn;
    }

    if (loggingIn) {
      return Routes.dashboard;
    }

    return null;
  }
}
