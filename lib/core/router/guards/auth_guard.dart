import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/authentication/application/providers/auth_state.dart';
import '../routes.dart';

final authGuardProvider = Provider<AuthGuard>((ref) => AuthGuard(ref));

class AuthGuard {
  AuthGuard(this.ref);

  final Ref ref;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authStateProvider);
    final path = state.matchedLocation;

    final onSplash = path == Routes.splash;
    final loggingIn = path == Routes.signIn;

    switch (authState) {
      case AuthInitial _:
        // Stay on current page while session is being checked
        return null;

      case AuthUnauthenticated _:
        // On splash: biarkan splash handle flow (video → sign-in)
        if (onSplash) return null;
        // On sign-in: stay
        if (loggingIn) return null;
        // Anywhere else: redirect to sign-in
        return Routes.signIn;

      case AuthAuthenticated _:
        // On splash or sign-in: go to dashboard
        if (onSplash || loggingIn) return Routes.dashboard;
        return null;
    }
  }
}
