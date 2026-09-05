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
import '../../features/student_portal/presentation/screens/student_dashboard_screen.dart';
import '../../features/assignments/presentation/screens/assignment_list_screen.dart';
import '../../features/assignments/presentation/screens/assignment_detail_screen.dart';
import '../../features/assignments/presentation/screens/assignment_grading_screen.dart';
import '../../features/assignments/presentation/screens/course_gradebook_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/session_detail_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_list_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_detail_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_exam_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_builder_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_analytics_screen.dart';
import '../../features/communications/presentation/screens/announcements_screen.dart';
import '../../features/communications/presentation/screens/discussions_screen.dart';
import '../../features/communications/presentation/screens/discussion_detail_screen.dart';

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
          builder: (context, state) {
            final authState = authCubit.state;
            if (authState is Authenticated && authState.user.role.isStudent) {
              return const StudentDashboardScreen();
            }
            return const InstructorDashboardScreen();
          },
        ),
        GoRoute(
          path: RouteConstants.instructorDashboard,
          name: 'instructor-dashboard',
          builder: (context, state) => const InstructorDashboardScreen(),
        ),
        GoRoute(
          path: RouteConstants.studentDashboard,
          name: 'student-dashboard',
          builder: (context, state) => const StudentDashboardScreen(),
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
        GoRoute(
          path: RouteConstants.assignments,
          name: 'assignments',
          builder: (context, state) => const AssignmentListScreen(),
        ),
        GoRoute(
          path: RouteConstants.assignmentDetail,
          name: 'assignment-detail',
          builder: (context, state) {
            final assignmentId = state.pathParameters['id'] ?? '';
            return AssignmentDetailScreen(assignmentId: assignmentId);
          },
        ),
        GoRoute(
          path: RouteConstants.assignmentGrading,
          name: 'assignment-grading',
          builder: (context, state) {
            final assignmentId = state.pathParameters['id'] ?? '';
            return AssignmentGradingScreen(assignmentId: assignmentId);
          },
        ),
        GoRoute(
          path: RouteConstants.gradebook,
          name: 'course-gradebook',
          builder: (context, state) {
            final courseId = state.pathParameters['id'] ?? '';
            return CourseGradebookScreen(courseId: courseId);
          },
        ),
        GoRoute(
          path: RouteConstants.attendance,
          name: 'attendance',
          builder: (context, state) => const AttendanceScreen(),
        ),
        GoRoute(
          path: RouteConstants.attendanceSessionDetail,
          name: 'attendance-session-detail',
          builder: (context, state) {
            final sessionId = state.pathParameters['id'] ?? '';
            return SessionDetailScreen(sessionId: sessionId);
          },
        ),
        GoRoute(
          path: RouteConstants.quizzes,
          name: 'quizzes',
          builder: (context, state) => const QuizListScreen(),
        ),
        GoRoute(
          path: RouteConstants.quizBuilder,
          name: 'quiz-builder',
          builder: (context, state) => const QuizBuilderScreen(),
        ),
        GoRoute(
          path: RouteConstants.quizDetail,
          name: 'quiz-detail',
          builder: (context, state) {
            final quizId = state.pathParameters['id'] ?? '';
            return QuizDetailScreen(quizId: quizId);
          },
        ),
        GoRoute(
          path: RouteConstants.quizExam,
          name: 'quiz-exam',
          builder: (context, state) {
            final quizId = state.pathParameters['id'] ?? '';
            return QuizExamScreen(quizId: quizId);
          },
        ),
        GoRoute(
          path: RouteConstants.quizAnalytics,
          name: 'quiz-analytics',
          builder: (context, state) {
            final quizId = state.pathParameters['id'] ?? '';
            return QuizAnalyticsScreen(quizId: quizId);
          },
        ),
        GoRoute(
          path: RouteConstants.announcements,
          name: 'announcements',
          builder: (context, state) => const AnnouncementsScreen(),
        ),
        GoRoute(
          path: RouteConstants.discussions,
          name: 'discussions',
          builder: (context, state) => const DiscussionsScreen(),
        ),
        GoRoute(
          path: RouteConstants.discussionDetail,
          name: 'discussion-detail',
          builder: (context, state) {
            final threadId = state.pathParameters['id'] ?? '';
            return DiscussionDetailScreen(threadId: threadId);
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
