import 'package:go_router/go_router.dart';
import '../di/dependency_injection.dart';
import '../../presentation/controllers/community_viewmodel.dart';
import '../../presentation/views/about_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/student_form_view.dart';
import '../../presentation/views/auth_view.dart';
import '../../presentation/views/assessment_view.dart';

class AppRouteNames {
  static const splash = 'splash',
      home = 'home',
      about = 'about',
      studentForm = 'student_form';
}

class AppPaths {
  static const splash = '/',
      home = '/home',
      about = '/about',
      studentForm = '/student-form';
  static const login = '/login', register = '/register';
}

class AppRouter {
  AppRouter._();
  static final GoRouter router = createRouter(
    injector.get<CommunityViewModel>(),
  );

  static GoRouter createRouter(
    CommunityViewModel vm, {
    String initialLocation = AppPaths.splash,
  }) => GoRouter(
    initialLocation: initialLocation,
    refreshListenable: vm.state,
    redirect: (context, state) {
      final path = state.uri.path;
      if (!vm.state.authenticationReady.value &&
          path != AppPaths.splash &&
          path != AppPaths.about) {
        return AppPaths.splash;
      }
      final authenticated = vm.state.session.value != null;
      final authPage = path == AppPaths.login || path == AppPaths.register;
      final public =
          authPage || path == AppPaths.splash || path == AppPaths.about;
      if (!authenticated && !public) return AppPaths.login;
      if (authenticated && authPage) return AppPaths.home;
      if (authenticated &&
          path == '/assess/${vm.state.session.value!.studentId}') {
        return AppPaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRouteNames.splash,
        builder: (_, _) => const SplashView(),
      ),
      GoRoute(path: AppPaths.login, builder: (_, _) => const LoginView()),
      GoRoute(path: AppPaths.register, builder: (_, _) => const RegisterView()),
      GoRoute(
        path: AppPaths.home,
        name: AppRouteNames.home,
        builder: (_, _) => const HomeView(),
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRouteNames.about,
        builder: (_, _) => const AboutView(),
      ),
      GoRoute(
        path: AppPaths.studentForm,
        name: AppRouteNames.studentForm,
        builder: (_, state) =>
            StudentFormView(personId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/assess/:id',
        builder: (_, state) =>
            AssessmentView(targetId: state.pathParameters['id']!),
      ),
    ],
  );
}
