import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:academic_portal/core/bloc/theme_cubit.dart';
import 'package:academic_portal/features/auth/domain/entities/user_entity.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_state.dart';
import 'package:academic_portal/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:academic_portal/features/courses/data/models/course_model.dart';
import 'package:academic_portal/features/courses/data/repositories/course_repository_impl.dart';
import 'package:academic_portal/features/courses/domain/entities/course_entity.dart';
import 'package:academic_portal/features/courses/presentation/cubit/course_form_cubit.dart';
import 'package:academic_portal/features/courses/presentation/cubit/course_form_state.dart';
import 'package:academic_portal/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:academic_portal/features/courses/presentation/cubit/courses_state.dart';
import 'package:academic_portal/features/courses/presentation/screens/course_create_screen.dart';
import 'package:academic_portal/features/courses/presentation/screens/course_detail_screen.dart';
import 'package:academic_portal/features/courses/presentation/screens/course_list_screen.dart';

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit({bool isInstructor = true})
      : super(
          Authenticated(
            UserEntity(
              id: 'demo-inst-01',
              email: 'prof.smith@academic.edu',
              displayName: 'Dr. Sarah Jenkins',
              role: isInstructor ? UserRole.instructor : UserRole.student,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Course Management Unit Tests', () {
    test('CourseModel & SyllabusItem serialize and deserialize correctly', () {
      final now = DateTime(2026, 8, 25, 10, 30);
      final course = CourseModel(
        id: 'c-test-01',
        code: 'CS-500',
        title: 'Distributed Systems',
        description: 'Fault-tolerant distributed computing paradigms.',
        instructorId: 'inst-1',
        instructorName: 'Dr. Ada Lovelace',
        term: 'Fall 2026',
        department: 'Computer Science',
        credits: 4,
        schedule: 'Tue / Thu • 11:00 AM',
        room: 'Lab 4',
        enrolledCount: 30,
        maxCapacity: 40,
        syllabus: const [
          SyllabusItem(
            weekNumber: 1,
            title: 'Consensus & Raft',
            description: 'Leader election, log replication, and safety.',
          ),
        ],
        createdAt: now,
      );

      final map = course.toMap();
      expect(map['code'], 'CS-500');
      expect(map['credits'], 4);
      expect((map['syllabus'] as List).length, 1);

      final deserialized = CourseModel.fromMap(map, 'c-test-01');
      expect(deserialized.id, 'c-test-01');
      expect(deserialized.title, 'Distributed Systems');
      expect(deserialized.syllabus.first.title, 'Consensus & Raft');
      expect(deserialized.isFull, false);
      expect(deserialized.enrollmentRatio, 0.75);
    });

    test('CoursesCubit loads, filters, and searches courses', () async {
      final dataSource = CourseRemoteDataSourceImpl();
      final repository = CourseRepositoryImpl(remoteDataSource: dataSource);
      final cubit = CoursesCubit(repository: repository);

      await cubit.loadCourses();
      expect(cubit.state, isA<CoursesLoaded>());
      final loaded = cubit.state as CoursesLoaded;
      expect(loaded.courses.length, 4);

      // Filter by department
      await cubit.filterByDepartment('Mathematics');
      expect(cubit.state, isA<CoursesLoaded>());
      final mathLoaded = cubit.state as CoursesLoaded;
      expect(mathLoaded.courses.length, 1);
      expect(mathLoaded.courses.first.code, 'MATH-201');

      // Search by keyword across all departments
      await cubit.filterByDepartment('All');
      await cubit.search('Neural');
      expect(cubit.state, isA<CoursesLoaded>());
      final searchLoaded = cubit.state as CoursesLoaded;
      expect(searchLoaded.courses.length, 1);
      expect(searchLoaded.courses.first.code, 'CS-420');

      // Load specific course details
      await cubit.loadCourseDetails('course-cs-301');
      final detailLoaded = cubit.state as CoursesLoaded;
      expect(detailLoaded.selectedCourse?.title, 'Data Structures & Algorithms');

      await cubit.close();
    });

    test('CourseFormCubit creates course offering successfully', () async {
      final dataSource = CourseRemoteDataSourceImpl();
      final repository = CourseRepositoryImpl(remoteDataSource: dataSource);
      final cubit = CourseFormCubit(repository: repository);

      expect(cubit.state, isA<CourseFormInitial>());

      await cubit.submitCourse(
        code: 'CS-305',
        title: 'Computer Networks',
        description: 'TCP/IP architecture, routing algorithms, and network security.',
        instructorId: 'demo-inst-01',
        instructorName: 'Dr. Sarah Jenkins',
        term: 'Fall 2026',
        department: 'Computer Science',
        credits: 3,
        schedule: 'Mon / Wed • 02:00 PM',
        room: 'Hall A-102',
        maxCapacity: 50,
        syllabus: const [
          SyllabusItem(
            weekNumber: 1,
            title: 'OSI & TCP/IP Reference Models',
            description: 'Layering principles and protocol encapsulation.',
          ),
        ],
      );

      expect(cubit.state, isA<CourseFormSuccess>());
      final success = cubit.state as CourseFormSuccess;
      expect(success.course.code, 'CS-305');
      expect(success.course.id.isNotEmpty, true);

      // Verify it is now present in the repository
      final allCourses = await repository.getCourses();
      expect(allCourses.any((c) => c.code == 'CS-305'), true);

      await cubit.close();
    });
  });

  group('Course Management Widget Tests', () {
    testWidgets('CourseListScreen renders catalog header, search bar, and course cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dataSource = CourseRemoteDataSourceImpl();
      final repository = CourseRepositoryImpl(remoteDataSource: dataSource);
      final coursesCubit = CoursesCubit(repository: repository);
      final fakeAuthCubit = FakeAuthCubit();
      final themeCubit = ThemeCubit();

      final router = GoRouter(
        initialLocation: '/courses',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/instructor-dashboard',
            builder: (_, __) => const Scaffold(body: Text('Dashboard')),
          ),
          GoRoute(
            path: '/design-system',
            builder: (_, __) => const Scaffold(body: Text('Design System')),
          ),
          GoRoute(
            path: '/courses',
            builder: (_, __) => const CourseListScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<AuthCubit>.value(value: fakeAuthCubit),
            BlocProvider<CoursesCubit>.value(value: coursesCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Academic Course Catalog'), findsOneWidget);
      expect(find.text('+ Create New Course'), findsOneWidget);

      // Check courses
      expect(find.text('CS-301'), findsOneWidget);
      expect(find.text('Data Structures & Algorithms'), findsOneWidget);
      expect(find.text('CS-420'), findsOneWidget);
      expect(find.text('MATH-201'), findsOneWidget);

      // Check department chips
      expect(find.text('Computer Science'), findsWidgets);
      expect(find.text('Software Engineering'), findsWidgets);
      expect(find.text('Mathematics'), findsWidgets);

      await coursesCubit.close();
      await fakeAuthCubit.close();
      await themeCubit.close();
    });

    testWidgets('CourseCreateScreen renders inputs, adds syllabus module and submits form',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dataSource = CourseRemoteDataSourceImpl();
      final repository = CourseRepositoryImpl(remoteDataSource: dataSource);
      final coursesCubit = CoursesCubit(repository: repository);
      final courseFormCubit = CourseFormCubit(repository: repository);
      final fakeAuthCubit = FakeAuthCubit();
      final themeCubit = ThemeCubit();

      final router = GoRouter(
        initialLocation: '/courses/create',
        routes: [
          GoRoute(
            path: '/courses',
            builder: (_, __) => const Scaffold(body: Text('Courses Catalog Screen')),
          ),
          GoRoute(
            path: '/courses/create',
            builder: (_, __) => const CourseCreateScreen(),
          ),
          GoRoute(
            path: '/courses/:id',
            builder: (_, state) =>
                Scaffold(body: Text('Course Details ${state.pathParameters['id']}')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<AuthCubit>.value(value: fakeAuthCubit),
            BlocProvider<CoursesCubit>.value(value: coursesCubit),
            BlocProvider<CourseFormCubit>.value(value: courseFormCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Course Offering'), findsOneWidget);
      expect(find.text('Publish Course Offering'), findsOneWidget);

      // Attempt submit without required fields to trigger validation
      await tester.ensureVisible(find.text('Publish Course Offering'));
      await tester.tap(find.text('Publish Course Offering'));
      await tester.pumpAndSettle();

      expect(find.text('Course code is required'), findsOneWidget);
      expect(find.text('Course title is required'), findsOneWidget);

      // Fill in required fields
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g., CS-305'), 'CS-302');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g., Advanced Database Systems'),
          'Advanced Database Systems');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g., Mon / Wed • 10:00 AM - 11:30 AM'),
          'Tue / Thu • 10:00 AM');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g., Turing Lab 2'), 'Hall B-101');

      // Submit form
      await tester.ensureVisible(find.text('Publish Course Offering'));
      await tester.tap(find.text('Publish Course Offering'));
      await tester.pumpAndSettle();

      // Should have successfully created and navigated to detail route
      expect(find.textContaining('Course Details course-'), findsOneWidget);

      await coursesCubit.close();
      await courseFormCubit.close();
      await fakeAuthCubit.close();
      await themeCubit.close();
    });

    testWidgets('CourseDetailScreen renders tabs, syllabus items, and section roster',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dataSource = CourseRemoteDataSourceImpl();
      final repository = CourseRepositoryImpl(remoteDataSource: dataSource);
      final coursesCubit = CoursesCubit(repository: repository);
      final fakeAuthCubit = FakeAuthCubit();
      final themeCubit = ThemeCubit();

      final router = GoRouter(
        initialLocation: '/courses/course-cs-301',
        routes: [
          GoRoute(
            path: '/courses',
            builder: (_, __) => const Scaffold(body: Text('Catalog')),
          ),
          GoRoute(
            path: '/courses/:id',
            builder: (_, state) =>
                CourseDetailScreen(courseId: state.pathParameters['id']!),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<AuthCubit>.value(value: fakeAuthCubit),
            BlocProvider<CoursesCubit>.value(value: coursesCubit),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check hero details
      expect(find.text('CS-301'), findsOneWidget);
      expect(find.text('Data Structures & Algorithms'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);

      // Check tabs
      expect(find.text('Overview & Logistics'), findsOneWidget);
      expect(find.text('Syllabus & Modules'), findsOneWidget);
      expect(find.text('Roster & Capacity'), findsOneWidget);

      // Check overview content
      expect(find.text('About this Course'), findsOneWidget);
      expect(find.text('Schedule & Location'), findsOneWidget);

      // Switch to Syllabus tab
      await tester.tap(find.text('Syllabus & Modules'));
      await tester.pumpAndSettle();

      expect(find.text('WEEK 1'), findsOneWidget);
      expect(find.text('Algorithmic Complexity & Big-O Notation'), findsOneWidget);
      expect(find.text('WEEK 2'), findsOneWidget);

      // Switch to Roster tab
      await tester.tap(find.text('Roster & Capacity'));
      await tester.pumpAndSettle();

      expect(find.text('Section Roster & Statistics'), findsOneWidget);
      expect(find.text('Download Section Roster (CSV)'), findsOneWidget);

      await coursesCubit.close();
      await fakeAuthCubit.close();
      await themeCubit.close();
    });
  });
}
