import 'package:go_router/go_router.dart';
import '../../domain/entity/student_entity.dart';
import '../../presentation/views/about_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/student_form_view.dart';

class AppRouteNames {
  static const splash = 'splash';
  static const home = 'home';
  static const about = 'about';
  static const studentForm = 'student_form';
}

class AppPaths {
  static const splash = '/';
  static const home = '/home';
  static const about = '/about';
  static const studentForm = '/student-form';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppPaths.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppPaths.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppPaths.home,
        name: AppRouteNames.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRouteNames.about,
        builder: (context, state) => const AboutView(),
      ),
      GoRoute(
        path: AppPaths.studentForm,
        name: AppRouteNames.studentForm,
        builder: (context, state) {
          final initialStudent = state.extra as Student?;
          return StudentFormView(initialStudent: initialStudent);
        },
      ),
    ],
  );
}
