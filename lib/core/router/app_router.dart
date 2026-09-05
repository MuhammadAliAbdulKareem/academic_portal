import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/design_system/presentation/screens/design_system_screen.dart';
import '../../features/foundation/presentation/screens/foundation_screen.dart';
import '../../features/instructor_dashboard/presentation/screens/instructor_dashboard_screen.dart';
import '../../features/courses/presentation/screens/course_create_screen.dart';
import '../../features/courses/presentation/screens/course_detail_screen.dart';
import '../../features/courses/presentation/screens/course_list_screen.dart';

/// Helper to bridge Stream changes to GoRouter's Listenable refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Global application navigation configuration utilizing GoRouter with Auth Guards.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteConstants.root,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuthenticated = authState is Authenticated;
        final isAuthRoute = state.uri.path == RouteConstants.login ||
            state.uri.path == RouteConstants.register;

        // If authenticated and trying to access login/register, redirect home
        if (isAuthenticated && isAuthRoute) {
          return RouteConstants.root;
        }

        // If route is protected and user is not authenticated
        final isProtectedRoute = state.uri.path.startsWith('/dashboard') ||
            state.uri.path.startsWith('/courses/create');

        if (!isAuthenticated && isProtectedRoute) {
          return RouteConstants.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteConstants.root,
          name: 'home',
          builder: (context, state) => const FoundationScreen(),
        ),
        GoRoute(
          path: RouteConstants.foundation,
          name: 'foundation',
          builder: (context, state) => const FoundationScreen(),
        ),
        GoRoute(
          path: RouteConstants.designSystem,
          name: 'design-system',
          builder: (context, state) => const DesignSystemScreen(),
        ),
        GoRoute(
          path: RouteConstants.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteConstants.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteConstants.dashboard,
          name: 'dashboard',
          builder: (context, state) => const InstructorDashboardScreen(),
        ),
        GoRoute(
          path: RouteConstants.instructorDashboard,
          name: 'instructor-dashboard',
          builder: (context, state) => const InstructorDashboardScreen(),
        ),
        GoRoute(
          path: RouteConstants.courses,
          name: 'courses',
          builder: (context, state) => const CourseListScreen(),
        ),
        GoRoute(
          path: RouteConstants.courseCreate,
          name: 'course-create',
          builder: (context, state) => const CourseCreateScreen(),
        ),
        GoRoute(
          path: RouteConstants.courseDetail,
          name: 'course-detail',
          builder: (context, state) {
            final courseId = state.pathParameters['id'] ?? '';
            return CourseDetailScreen(courseId: courseId);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  '404 - Page Not Found',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'The path ${state.uri.path} does not exist.',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go(RouteConstants.root),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
