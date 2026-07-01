import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academic_year/presentation/pages/academic_year_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/authentication/application/providers/auth_state.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/assessment/presentation/pages/assessment_page.dart';
import '../../features/class/presentation/pages/class_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/parent/presentation/pages/parent_page.dart';
import '../../features/report/presentation/pages/report_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/student/presentation/pages/student_page.dart';
import '../../shared/pages/splash_page.dart';
import 'adaptive_shell.dart';
import 'guards/auth_guard.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = ref.read(authGuardProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    redirect: authGuard.handleRedirect,
    refreshListenable: AuthRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashPage(),
        ),
      ),
      GoRoute(
        path: Routes.signIn,
        name: Routes.signIn,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SignInPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AdaptiveShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            name: Routes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: Routes.report,
            name: Routes.report,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportPage(),
            ),
          ),
          GoRoute(
            path: Routes.classes,
            name: Routes.classes,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClassPage(),
            ),
          ),
          GoRoute(
            path: Routes.classTambah,
            name: Routes.classTambah,
            builder: (context, state) => const ClassFormPage(),
          ),
          GoRoute(
            path: Routes.classEdit,
            name: Routes.classEdit,
            builder: (context, state) => const ClassFormPage(),
          ),
          GoRoute(
            path: Routes.students,
            name: Routes.students,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StudentPage(),
            ),
          ),
          GoRoute(
            path: Routes.studentTambah,
            name: Routes.studentTambah,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StudentFormPage(),
            ),
          ),
          GoRoute(
            path: Routes.studentEdit,
            name: Routes.studentEdit,
            builder: (context, state) => const StudentFormPage(),
          ),
          GoRoute(
            path: Routes.absensi,
            name: Routes.absensi,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AttendancePage(),
            ),
          ),
          GoRoute(
            path: Routes.penilaian,
            name: Routes.penilaian,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AssessmentPage(),
            ),
          ),
          GoRoute(
            path: Routes.profil,
            name: Routes.profil,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ParentPage(),
            ),
          ),
          GoRoute(
            path: Routes.academicYears,
            name: Routes.academicYears,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AcademicYearPage(),
            ),
          ),
          GoRoute(
            path: Routes.academicYearTambah,
            name: Routes.academicYearTambah,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AcademicYearFormPage(),
            ),
          ),
          GoRoute(
            path: Routes.academicYearEdit,
            name: Routes.academicYearEdit,
            builder: (context, state) => const AcademicYearFormPage(),
          ),
          GoRoute(
            path: Routes.settings,
            name: Routes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
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
