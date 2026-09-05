import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:academic_portal/core/bloc/theme_cubit.dart';
import 'package:academic_portal/features/auth/domain/entities/user_entity.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_state.dart';
import 'package:academic_portal/features/instructor_dashboard/data/datasources/instructor_dashboard_remote_data_source.dart';
import 'package:academic_portal/features/instructor_dashboard/data/repositories/instructor_dashboard_repository_impl.dart';
import 'package:academic_portal/features/instructor_dashboard/domain/entities/dashboard_entities.dart';
import 'package:academic_portal/features/instructor_dashboard/domain/repositories/instructor_dashboard_repository.dart';
import 'package:academic_portal/features/instructor_dashboard/presentation/cubit/instructor_dashboard_cubit.dart';
import 'package:academic_portal/features/instructor_dashboard/presentation/cubit/instructor_dashboard_state.dart';
import 'package:academic_portal/features/instructor_dashboard/presentation/screens/instructor_dashboard_screen.dart';

class FailingMockRepository implements InstructorDashboardRepository {
  @override
  Future<InstructorDashboardStats> getStats(String instructorId) async {
    throw Exception('Failed to load instructor stats');
  }

  @override
  Future<List<CourseSummaryEntity>> getCourses(String instructorId) async {
    throw Exception('Failed to load instructor courses');
  }

  @override
  Future<List<RecentActivityEntity>> getRecentActivities(String instructorId) async {
    throw Exception('Failed to load recent activities');
  }

  @override
  Future<List<UpcomingDeadlineEntity>> getUpcomingDeadlines(String instructorId) async {
    throw Exception('Failed to load upcoming deadlines');
  }
}

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit()
      : super(
          Authenticated(
            UserEntity(
              id: 'demo-inst-01',
              email: 'prof.smith@academic.edu',
              displayName: 'Dr. Sarah Jenkins',
              role: UserRole.instructor,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('InstructorDashboardCubit Unit Tests', () {
    late InstructorDashboardRemoteDataSource dataSource;
    late InstructorDashboardRepository repository;
    late InstructorDashboardCubit cubit;

    setUp(() {
      dataSource = InstructorDashboardRemoteDataSourceImpl();
      repository = InstructorDashboardRepositoryImpl(remoteDataSource: dataSource);
      cubit = InstructorDashboardCubit(repository: repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is InstructorDashboardInitial', () {
      expect(cubit.state, isA<InstructorDashboardInitial>());
    });

    test('loadDashboard emits Loading and then Loaded with comprehensive data',
        () async {
      final expectedStates = <Type>[];
      final subscription = cubit.stream.listen((state) {
        expectedStates.add(state.runtimeType);
      });

      await cubit.loadDashboard('demo-inst-01');
      await pumpEventQueue();

      expect(expectedStates, [InstructorDashboardLoading, InstructorDashboardLoaded]);
      expect(cubit.state, isA<InstructorDashboardLoaded>());

      final loaded = cubit.state as InstructorDashboardLoaded;
      expect(loaded.stats.activeCourses, 3);
      expect(loaded.stats.totalStudents, 136);
      expect(loaded.stats.pendingGrading, 18);
      expect(loaded.stats.attendanceRate, 94.2);
      expect(loaded.courses.length, 3);
      expect(loaded.activities.isNotEmpty, true);
      expect(loaded.deadlines.isNotEmpty, true);

      await subscription.cancel();
    });

    test('refreshDashboard reloads data cleanly', () async {
      await cubit.loadDashboard('demo-inst-01');
      expect(cubit.state, isA<InstructorDashboardLoaded>());

      await cubit.refreshDashboard('demo-inst-01');
      expect(cubit.state, isA<InstructorDashboardLoaded>());
    });

    test('emits InstructorDashboardError when repository throws', () async {
      final failingRepo = FailingMockRepository();
      final failingCubit = InstructorDashboardCubit(repository: failingRepo);

      await failingCubit.loadDashboard('invalid-id');

      expect(failingCubit.state, isA<InstructorDashboardError>());
      final errorState = failingCubit.state as InstructorDashboardError;
      expect(errorState.message, contains('Failed to load instructor stats'));

      await failingCubit.close();
    });
  });

  group('InstructorDashboardScreen Widget Tests', () {
    testWidgets('renders KPI metrics, course cards, quick actions, and tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dataSource = InstructorDashboardRemoteDataSourceImpl();
      final repository = InstructorDashboardRepositoryImpl(remoteDataSource: dataSource);
      final dashboardCubit = InstructorDashboardCubit(repository: repository);
      final fakeAuthCubit = FakeAuthCubit();
      final themeCubit = ThemeCubit();

      final router = GoRouter(
        initialLocation: '/instructor-dashboard',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home Screen')),
          ),
          GoRoute(
            path: '/design-system',
            builder: (_, __) => const Scaffold(body: Text('Design System')),
          ),
          GoRoute(
            path: '/instructor-dashboard',
            builder: (_, __) => const InstructorDashboardScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<AuthCubit>.value(value: fakeAuthCubit),
            BlocProvider<InstructorDashboardCubit>.value(value: dashboardCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Trigger initial load and wait for mock remote delay
      await tester.pumpAndSettle();

      // Check header and greeting
      expect(find.text('INSTRUCTOR PORTAL'), findsOneWidget);
      expect(find.text('Welcome back, Dr. Sarah Jenkins'), findsOneWidget);

      // Check KPI Metric Cards
      expect(find.text('Active Courses'), findsWidgets);
      expect(find.text('Enrolled Students'), findsOneWidget);
      expect(find.text('Pending Grading'), findsWidgets);
      expect(find.text('Average Attendance'), findsOneWidget);

      // Check Course Overview Cards
      expect(find.text('CS-301'), findsWidgets);
      expect(find.text('Data Structures & Algorithms'), findsOneWidget);
      expect(find.text('CS-420'), findsWidgets);

      // Test tapping action button triggers SnackBar
      await tester.ensureVisible(find.text('+ Create New Course'));
      await tester.tap(find.text('+ Create New Course'));
      await tester.pump();

      expect(
        find.text('Course Creation module is scheduled for Feature 5!'),
        findsOneWidget,
      );

      await dashboardCubit.close();
      await fakeAuthCubit.close();
      await themeCubit.close();
    });

    testWidgets('renders error state and retry button on failure',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final failingRepo = FailingMockRepository();
      final failingCubit = InstructorDashboardCubit(repository: failingRepo);
      final fakeAuthCubit = FakeAuthCubit();
      final themeCubit = ThemeCubit();

      final router = GoRouter(
        initialLocation: '/instructor-dashboard',
        routes: [
          GoRoute(
            path: '/instructor-dashboard',
            builder: (_, __) => const InstructorDashboardScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<AuthCubit>.value(value: fakeAuthCubit),
            BlocProvider<InstructorDashboardCubit>.value(value: failingCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load instructor stats'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await failingCubit.close();
      await fakeAuthCubit.close();
      await themeCubit.close();
    });
  });
}
