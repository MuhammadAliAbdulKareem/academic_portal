import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academic_portal/core/bloc/theme_cubit.dart';
import 'package:academic_portal/features/auth/domain/entities/user_entity.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_state.dart';
import 'package:academic_portal/features/courses/domain/entities/course_entity.dart';
import 'package:academic_portal/features/student_portal/data/datasources/enrollment_remote_data_source.dart';
import 'package:academic_portal/features/student_portal/data/models/enrollment_model.dart';
import 'package:academic_portal/features/student_portal/data/repositories/enrollment_repository_impl.dart';
import 'package:academic_portal/features/student_portal/domain/entities/enrollment_entity.dart';
import 'package:academic_portal/features/student_portal/presentation/cubit/enrollment_cubit.dart';
import 'package:academic_portal/features/student_portal/presentation/cubit/enrollment_state.dart';
import 'package:academic_portal/features/student_portal/presentation/cubit/student_dashboard_cubit.dart';
import 'package:academic_portal/features/student_portal/presentation/cubit/student_dashboard_state.dart';
import 'package:academic_portal/features/student_portal/presentation/screens/student_dashboard_screen.dart';
import 'package:academic_portal/features/student_portal/presentation/widgets/enrolled_course_card.dart';
import 'package:academic_portal/features/student_portal/presentation/widgets/student_deadline_card.dart';
import 'package:academic_portal/features/student_portal/presentation/widgets/student_schedule_card.dart';

class FakeStudentAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeStudentAuthCubit()
      : super(
          Authenticated(
            UserEntity(
              id: 'demo-student-01',
              email: 'alex.student@academic.edu',
              displayName: 'Alex Mercer',
              role: UserRole.student,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Student Portal Unit Tests', () {
    test('EnrollmentModel serializes and deserializes correctly', () {
      final now = DateTime(2026, 8, 20);
      final model = EnrollmentModel(
        id: 'enr-test-01',
        studentId: 'demo-student-01',
        courseId: 'course-cs-301',
        courseCode: 'CS-301',
        courseTitle: 'Data Structures & Algorithms',
        instructorName: 'Dr. Sarah Jenkins',
        department: 'Computer Science',
        term: 'Fall 2026',
        credits: 4,
        schedule: 'Mon / Wed • 10:00 AM',
        room: 'Hall B-104',
        status: EnrollmentStatus.active,
        enrolledAt: now,
        grade: 'A',
        completedModules: 3,
        totalModules: 5,
      );

      final map = model.toMap();
      expect(map['courseCode'], 'CS-301');
      expect(map['status'], 'active');
      expect(map['completedModules'], 3);

      final restored = EnrollmentModel.fromMap(map, 'enr-test-01');
      expect(restored.id, 'enr-test-01');
      expect(restored.courseTitle, 'Data Structures & Algorithms');
      expect(restored.credits, 4);
      expect(restored.status, EnrollmentStatus.active);
      expect(restored.progressRatio, 0.6);
      expect(restored.isActive, isTrue);
    });

    test('EnrollmentRepositoryImpl performs enrollment and retrieval', () async {
      final dataSource = EnrollmentRemoteDataSourceImpl();
      final repository = EnrollmentRepositoryImpl(remoteDataSource: dataSource);

      final enrollments = await repository.getStudentEnrollments('demo-student-01');
      expect(enrollments.length, 2);
      expect(enrollments.first.courseCode, 'CS-301');

      final isEnrolledCS = await repository.isEnrolled(
        studentId: 'demo-student-01',
        courseId: 'course-cs-301',
      );
      expect(isEnrolledCS, isTrue);

      final isEnrolledMath = await repository.isEnrolled(
        studentId: 'demo-student-01',
        courseId: 'course-math-201',
      );
      expect(isEnrolledMath, isFalse);

      final stats = await repository.getStudentDashboardStats('demo-student-01');
      expect(stats.gpa, 3.84);
      expect(stats.enrolledCredits, 7);

      final schedule = await repository.getTodaySchedule('demo-student-01');
      expect(schedule.length, 2);

      final deadlines = await repository.getUpcomingDeadlines('demo-student-01');
      expect(deadlines.isNotEmpty, isTrue);
    });

    test('EnrollmentCubit manages registrations and enforces credit limits', () async {
      final dataSource = EnrollmentRemoteDataSourceImpl();
      final repository = EnrollmentRepositoryImpl(remoteDataSource: dataSource);
      final cubit = EnrollmentCubit(repository: repository);

      await cubit.loadEnrollments('demo-student-01');
      expect(cubit.state, isA<EnrollmentLoaded>());
      final loaded = cubit.state as EnrollmentLoaded;
      expect(loaded.enrollments.length, 2);
      expect(loaded.totalCredits, 7);
      expect(loaded.isEnrolled('course-cs-301'), isTrue);

      // Enroll in a new course
      final newCourse = CourseEntity(
        id: 'course-se-210',
        code: 'SE-210',
        title: 'Software Engineering Paradigms',
        description: 'Design patterns and agile principles.',
        instructorId: 'demo-inst-02',
        instructorName: 'Prof. David Chen',
        term: 'Fall 2026',
        department: 'Software Engineering',
        credits: 3,
        schedule: 'Tue / Thu • 10:00 AM',
        room: 'Lab 4',
        createdAt: DateTime.now(),
      );

      await cubit.enroll(studentId: 'demo-student-01', course: newCourse);
      final afterEnroll = cubit.state as EnrollmentLoaded;
      expect(afterEnroll.enrollments.length, 3);
      expect(afterEnroll.totalCredits, 10);
      expect(afterEnroll.isEnrolled('course-se-210'), isTrue);

      // Attempt to enroll in duplicate course
      await cubit.enroll(studentId: 'demo-student-01', course: newCourse);
      final duplicateState = cubit.state as EnrollmentLoaded;
      expect(duplicateState.message, contains('already registered'));

      // Attempt to enroll exceeding 18 credits
      final hugeCourse = CourseEntity(
        id: 'course-huge',
        code: 'HUGE-900',
        title: 'Massive Dissertation',
        description: 'Exceeding credits limit.',
        instructorId: 'inst-09',
        instructorName: 'Dean',
        term: 'Fall 2026',
        department: 'Graduate',
        credits: 12, // 10 + 12 = 22 > 18
        schedule: 'Daily',
        room: 'Room 1',
        createdAt: DateTime.now(),
      );

      await cubit.enroll(studentId: 'demo-student-01', course: hugeCourse);
      expect(cubit.state, isA<EnrollmentError>());
      final errorState = cubit.state as EnrollmentError;
      expect(errorState.message, contains('limit of 18 credit hours'));

      // Drop course
      await cubit.drop(studentId: 'demo-student-01', courseId: 'course-se-210');
      final droppedState = cubit.state as EnrollmentLoaded;
      expect(droppedState.isEnrolled('course-se-210'), isFalse);
      expect(droppedState.totalCredits, 7);

      await cubit.close();
    });

    test('StudentDashboardCubit loads stats, schedule, and submits task', () async {
      final dataSource = EnrollmentRemoteDataSourceImpl();
      final repository = EnrollmentRepositoryImpl(remoteDataSource: dataSource);
      final cubit = StudentDashboardCubit(repository: repository);

      await cubit.loadDashboard('demo-student-01');
      expect(cubit.state, isA<StudentDashboardLoaded>());
      final loaded = cubit.state as StudentDashboardLoaded;
      expect(loaded.stats.gpa, 3.84);
      expect(loaded.todaySchedule.length, 2);
      expect(loaded.enrolledCourses.length, 2);
      expect(loaded.upcomingDeadlines.length, 3);

      await cubit.submitAssignment(
        studentId: 'demo-student-01',
        deadlineId: 'task-01',
      );
      final afterSubmit = cubit.state as StudentDashboardLoaded;
      final task = afterSubmit.upcomingDeadlines.firstWhere((d) => d.id == 'task-01');
      expect(task.status, DeadlineStatus.submitted);

      await cubit.close();
    });
  });

  group('Student Portal Widget Tests', () {
    testWidgets('StudentScheduleCard renders lecture info and live badge', (tester) async {
      const item = StudentScheduleItem(
        courseCode: 'CS-420',
        courseTitle: 'Artificial Intelligence',
        instructorName: 'Dr. Sarah Jenkins',
        time: '02:00 PM - 03:30 PM',
        room: 'Turing Lab 3',
        dayOfWeek: 'Tue / Thu',
        isLiveNow: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StudentScheduleCard(item: item),
          ),
        ),
      );

      expect(find.text('CS-420'), findsOneWidget);
      expect(find.text('Artificial Intelligence'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Turing Lab 3'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
    });

    testWidgets('EnrolledCourseCard renders progress bar and triggers actions', (tester) async {
      final enrollment = EnrollmentEntity(
        id: 'enr-01',
        studentId: 'demo-student-01',
        courseId: 'course-cs-301',
        courseCode: 'CS-301',
        courseTitle: 'Data Structures & Algorithms',
        instructorName: 'Dr. Sarah Jenkins',
        department: 'Computer Science',
        term: 'Fall 2026',
        credits: 4,
        schedule: 'Mon / Wed • 10:00 AM',
        room: 'Hall B-104',
        status: EnrollmentStatus.active,
        enrolledAt: DateTime.now(),
        grade: 'A-',
        completedModules: 3,
        totalModules: 5,
      );

      bool detailsTapped = false;
      bool dropTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              width: 350,
              child: EnrolledCourseCard(
                enrollment: enrollment,
                onViewDetails: () => detailsTapped = true,
                onDrop: () => dropTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('CS-301'), findsOneWidget);
      expect(find.text('Data Structures & Algorithms'), findsOneWidget);
      expect(find.text('Grade: A-'), findsOneWidget);
      expect(find.text('4 Credits'), findsOneWidget);
      expect(find.text('60% • Mod 3/5'), findsOneWidget);

      await tester.tap(find.text('View Syllabus'));
      expect(detailsTapped, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      expect(dropTapped, isTrue);
    });

    testWidgets('StudentDeadlineCard renders assignment and triggers submit', (tester) async {
      final deadline = StudentDeadlineItem(
        id: 'task-01',
        courseCode: 'CS-301',
        title: 'Programming Assignment 2',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        points: 100,
        type: DeadlineType.assignment,
        status: DeadlineStatus.pending,
      );

      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentDeadlineCard(
              item: deadline,
              onSubmit: () => submitted = true,
            ),
          ),
        ),
      );

      expect(find.text('CS-301'), findsOneWidget);
      expect(find.text('Programming Assignment 2'), findsOneWidget);
      expect(find.text('• 100 pts'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.text('Submit'));
      expect(submitted, isTrue);
    });

    testWidgets('StudentDashboardScreen renders greeting, KPIs, and timetable', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dataSource = EnrollmentRemoteDataSourceImpl();
      final repository = EnrollmentRepositoryImpl(remoteDataSource: dataSource);
      final authCubit = FakeStudentAuthCubit();
      final dashboardCubit = StudentDashboardCubit(repository: repository);
      final enrollmentCubit = EnrollmentCubit(repository: repository);
      final themeCubit = ThemeCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<StudentDashboardCubit>.value(value: dashboardCubit),
            BlocProvider<EnrollmentCubit>.value(value: enrollmentCubit),
          ],
          child: const MaterialApp(
            home: StudentDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Alex Mercer!'), findsOneWidget);
      expect(find.text('Cumulative GPA'), findsOneWidget);
      expect(find.text('Enrolled Credits'), findsOneWidget);
      expect(find.text('Attendance Standing'), findsOneWidget);
      expect(find.text('Today\'s Class Schedule (2)'), findsOneWidget);
      expect(find.text('My Enrolled Courses (2)'), findsOneWidget);
      expect(find.text('Upcoming Deadlines & Submissions (3)'), findsOneWidget);
    });
  });
}
