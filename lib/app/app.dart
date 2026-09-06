import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/bloc/theme_cubit.dart';
import '../core/bloc/theme_state.dart';
import '../core/constants/app_constants.dart';
import '../core/firebase/firebase_config.dart';
import '../core/firebase/firebase_seeder.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/courses/data/datasources/course_remote_data_source.dart';
import '../features/courses/data/repositories/course_repository_impl.dart';
import '../features/courses/domain/repositories/course_repository.dart';
import '../features/courses/presentation/cubit/course_form_cubit.dart';
import '../features/courses/presentation/cubit/courses_cubit.dart';
import '../features/instructor_dashboard/data/datasources/instructor_dashboard_remote_data_source.dart';
import '../features/instructor_dashboard/data/repositories/instructor_dashboard_repository_impl.dart';
import '../features/instructor_dashboard/domain/repositories/instructor_dashboard_repository.dart';
import '../features/instructor_dashboard/presentation/cubit/instructor_dashboard_cubit.dart';
import '../features/student_portal/data/datasources/enrollment_remote_data_source.dart';
import '../features/student_portal/data/repositories/enrollment_repository_impl.dart';
import '../features/student_portal/domain/repositories/enrollment_repository.dart';
import '../features/student_portal/presentation/cubit/enrollment_cubit.dart';
import '../features/student_portal/presentation/cubit/student_dashboard_cubit.dart';
import '../features/assignments/data/datasources/assignment_remote_data_source.dart';
import '../features/assignments/data/repositories/assignment_repository_impl.dart';
import '../features/assignments/domain/repositories/assignment_repository.dart';
import '../features/assignments/presentation/cubit/assignment_detail_cubit.dart';
import '../features/assignments/presentation/cubit/assignment_list_cubit.dart';
import '../features/assignments/presentation/cubit/gradebook_cubit.dart';
import '../features/assignments/presentation/cubit/grading_cubit.dart';
import '../features/assignments/presentation/cubit/submission_cubit.dart';
import '../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../features/attendance/domain/repositories/attendance_repository.dart';
import '../features/attendance/presentation/cubit/attendance_roster_cubit.dart';
import '../features/attendance/presentation/cubit/attendance_session_cubit.dart';
import '../features/attendance/presentation/cubit/student_attendance_history_cubit.dart';
import '../features/attendance/presentation/cubit/student_check_in_cubit.dart';
import '../features/quizzes/data/datasources/quiz_remote_data_source.dart';
import '../features/quizzes/data/repositories/quiz_repository_impl.dart';
import '../features/quizzes/domain/repositories/quiz_repository.dart';
import '../features/quizzes/presentation/cubit/quiz_analytics_cubit.dart';
import '../features/quizzes/presentation/cubit/quiz_builder_cubit.dart';
import '../features/quizzes/presentation/cubit/quiz_detail_cubit.dart';
import '../features/quizzes/presentation/cubit/quiz_exam_session_cubit.dart';
import '../features/quizzes/presentation/cubit/quiz_list_cubit.dart';
import '../features/communications/data/datasources/communications_remote_data_source.dart';
import '../features/communications/data/repositories/communications_repository_impl.dart';
import '../features/communications/domain/repositories/communications_repository.dart';
import '../features/communications/presentation/cubit/announcements_cubit.dart';
import '../features/communications/presentation/cubit/discussions_cubit.dart';
import '../features/communications/presentation/cubit/discussion_detail_cubit.dart';
import '../features/communications/presentation/cubit/notifications_cubit.dart';

/// Root application widget configuring global providers, router, and reactive theming.
class AcademicPortalApp extends StatefulWidget {
  final AuthRepository? authRepository;
  final CourseRepository? courseRepository;
  final InstructorDashboardRepository? instructorDashboardRepository;
  final EnrollmentRepository? enrollmentRepository;
  final AssignmentRepository? assignmentRepository;
  final AttendanceRepository? attendanceRepository;
  final QuizRepository? quizRepository;
  final CommunicationsRepository? communicationsRepository;

  const AcademicPortalApp({
    super.key,
    this.authRepository,
    this.courseRepository,
    this.instructorDashboardRepository,
    this.enrollmentRepository,
    this.assignmentRepository,
    this.attendanceRepository,
    this.quizRepository,
    this.communicationsRepository,
  });

  @override
  State<AcademicPortalApp> createState() => _AcademicPortalAppState();
}

class _AcademicPortalAppState extends State<AcademicPortalApp> {
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final CourseRepository _courseRepository;
  late final CoursesCubit _coursesCubit;
  late final CourseFormCubit _courseFormCubit;
  late final InstructorDashboardRepository _instructorDashboardRepository;
  late final InstructorDashboardCubit _instructorDashboardCubit;
  late final EnrollmentRepository _enrollmentRepository;
  late final EnrollmentCubit _enrollmentCubit;
  late final StudentDashboardCubit _studentDashboardCubit;
  late final AssignmentRepository _assignmentRepository;
  late final AssignmentListCubit _assignmentListCubit;
  late final AssignmentDetailCubit _assignmentDetailCubit;
  late final SubmissionCubit _submissionCubit;
  late final GradingCubit _gradingCubit;
  late final GradebookCubit _gradebookCubit;
  late final AttendanceRepository _attendanceRepository;
  late final AttendanceSessionCubit _attendanceSessionCubit;
  late final AttendanceRosterCubit _attendanceRosterCubit;
  late final StudentCheckInCubit _studentCheckInCubit;
  late final StudentAttendanceHistoryCubit _studentAttendanceHistoryCubit;
  late final QuizRepository _quizRepository;
  late final QuizListCubit _quizListCubit;
  late final QuizDetailCubit _quizDetailCubit;
  late final QuizExamSessionCubit _quizExamSessionCubit;
  late final QuizBuilderCubit _quizBuilderCubit;
  late final QuizAnalyticsCubit _quizAnalyticsCubit;
  late final CommunicationsRepository _communicationsRepository;
  late final AnnouncementsCubit _announcementsCubit;
  late final DiscussionsCubit _discussionsCubit;
  late final DiscussionDetailCubit _discussionDetailCubit;
  late final NotificationsCubit _notificationsCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final firestore =
        FirebaseConfig.isInitialized ? FirebaseFirestore.instance : null;

    if (firestore != null) {
      FirebaseSeeder.seedIfEmpty(firestore);
    }

    _authRepository = widget.authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(
            auth: FirebaseConfig.isInitialized ? FirebaseAuth.instance : null,
            firestore: firestore,
          ),
        );

    _courseRepository = widget.courseRepository ??
        CourseRepositoryImpl(
          remoteDataSource: CourseRemoteDataSourceImpl(firestore: firestore),
        );

    _instructorDashboardRepository = widget.instructorDashboardRepository ??
        InstructorDashboardRepositoryImpl(
          remoteDataSource:
              InstructorDashboardRemoteDataSourceImpl(firestore: firestore),
        );

    _enrollmentRepository = widget.enrollmentRepository ??
        EnrollmentRepositoryImpl(
          remoteDataSource:
              EnrollmentRemoteDataSourceImpl(firestore: firestore),
        );

    _assignmentRepository = widget.assignmentRepository ??
        AssignmentRepositoryImpl(
          remoteDataSource:
              AssignmentRemoteDataSourceImpl(firestore: firestore),
        );

    _attendanceRepository = widget.attendanceRepository ??
        AttendanceRepositoryImpl(
          remoteDataSource:
              AttendanceRemoteDataSourceImpl(firestore: firestore),
        );

    _quizRepository = widget.quizRepository ??
        QuizRepositoryImpl(
          remoteDataSource: QuizRemoteDataSourceImpl(firestore: firestore),
        );

    _communicationsRepository = widget.communicationsRepository ??
        CommunicationsRepositoryImpl(
          remoteDataSource: CommunicationsRemoteDataSourceImpl(firestore: firestore),
        );

    _authCubit = AuthCubit(authRepository: _authRepository);
    _themeCubit = ThemeCubit();
    _coursesCubit = CoursesCubit(repository: _courseRepository);
    _courseFormCubit = CourseFormCubit(repository: _courseRepository);
    _instructorDashboardCubit =
        InstructorDashboardCubit(repository: _instructorDashboardRepository);
    _enrollmentCubit = EnrollmentCubit(repository: _enrollmentRepository);
    _studentDashboardCubit =
        StudentDashboardCubit(repository: _enrollmentRepository);
    _assignmentListCubit = AssignmentListCubit(repository: _assignmentRepository);
    _assignmentDetailCubit = AssignmentDetailCubit(repository: _assignmentRepository);
    _submissionCubit = SubmissionCubit(repository: _assignmentRepository);
    _gradingCubit = GradingCubit(repository: _assignmentRepository);
    _gradebookCubit = GradebookCubit(repository: _assignmentRepository);
    _attendanceSessionCubit = AttendanceSessionCubit(repository: _attendanceRepository);
    _attendanceRosterCubit = AttendanceRosterCubit(repository: _attendanceRepository);
    _studentCheckInCubit = StudentCheckInCubit(repository: _attendanceRepository);
    _studentAttendanceHistoryCubit =
        StudentAttendanceHistoryCubit(repository: _attendanceRepository);
    _quizListCubit = QuizListCubit(repository: _quizRepository);
    _quizDetailCubit = QuizDetailCubit(repository: _quizRepository);
    _quizExamSessionCubit = QuizExamSessionCubit(repository: _quizRepository);
    _quizBuilderCubit = QuizBuilderCubit(repository: _quizRepository);
    _quizAnalyticsCubit = QuizAnalyticsCubit(repository: _quizRepository);
    _announcementsCubit = AnnouncementsCubit(repository: _communicationsRepository);
    _discussionsCubit = DiscussionsCubit(repository: _communicationsRepository);
    _discussionDetailCubit = DiscussionDetailCubit(repository: _communicationsRepository);
    _notificationsCubit = NotificationsCubit(repository: _communicationsRepository)
      ..loadNotifications('demo-student-01');

    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _themeCubit.close();
    _coursesCubit.close();
    _courseFormCubit.close();
    _instructorDashboardCubit.close();
    _enrollmentCubit.close();
    _studentDashboardCubit.close();
    _assignmentListCubit.close();
    _assignmentDetailCubit.close();
    _submissionCubit.close();
    _gradingCubit.close();
    _gradebookCubit.close();
    _attendanceSessionCubit.close();
    _attendanceRosterCubit.close();
    _studentCheckInCubit.close();
    _studentAttendanceHistoryCubit.close();
    _quizListCubit.close();
    _quizDetailCubit.close();
    _quizExamSessionCubit.close();
    _quizBuilderCubit.close();
    _quizAnalyticsCubit.close();
    _announcementsCubit.close();
    _discussionsCubit.close();
    _discussionDetailCubit.close();
    _notificationsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AssignmentRepository>.value(value: _assignmentRepository),
        RepositoryProvider<AttendanceRepository>.value(value: _attendanceRepository),
        RepositoryProvider<QuizRepository>.value(value: _quizRepository),
        RepositoryProvider<CommunicationsRepository>.value(value: _communicationsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: _themeCubit),
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<InstructorDashboardCubit>.value(
              value: _instructorDashboardCubit),
          BlocProvider<CoursesCubit>.value(value: _coursesCubit),
          BlocProvider<CourseFormCubit>.value(value: _courseFormCubit),
          BlocProvider<EnrollmentCubit>.value(value: _enrollmentCubit),
          BlocProvider<StudentDashboardCubit>.value(value: _studentDashboardCubit),
          BlocProvider<AssignmentListCubit>.value(value: _assignmentListCubit),
          BlocProvider<AssignmentDetailCubit>.value(value: _assignmentDetailCubit),
          BlocProvider<SubmissionCubit>.value(value: _submissionCubit),
          BlocProvider<GradingCubit>.value(value: _gradingCubit),
          BlocProvider<GradebookCubit>.value(value: _gradebookCubit),
          BlocProvider<AttendanceSessionCubit>.value(value: _attendanceSessionCubit),
          BlocProvider<AttendanceRosterCubit>.value(value: _attendanceRosterCubit),
          BlocProvider<StudentCheckInCubit>.value(value: _studentCheckInCubit),
          BlocProvider<StudentAttendanceHistoryCubit>.value(
              value: _studentAttendanceHistoryCubit),
          BlocProvider<QuizListCubit>.value(value: _quizListCubit),
          BlocProvider<QuizDetailCubit>.value(value: _quizDetailCubit),
          BlocProvider<QuizExamSessionCubit>.value(value: _quizExamSessionCubit),
          BlocProvider<QuizBuilderCubit>.value(value: _quizBuilderCubit),
          BlocProvider<QuizAnalyticsCubit>.value(value: _quizAnalyticsCubit),
          BlocProvider<AnnouncementsCubit>.value(value: _announcementsCubit),
          BlocProvider<DiscussionsCubit>.value(value: _discussionsCubit),
          BlocProvider<DiscussionDetailCubit>.value(value: _discussionDetailCubit),
          BlocProvider<NotificationsCubit>.value(value: _notificationsCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
