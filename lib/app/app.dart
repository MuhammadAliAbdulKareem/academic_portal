import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/bloc/theme_cubit.dart';
import '../core/bloc/theme_state.dart';
import '../core/constants/app_constants.dart';
import '../core/firebase/firebase_config.dart';
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

/// Root application widget configuring global providers, router, and reactive theming.
class AcademicPortalApp extends StatefulWidget {
  final AuthRepository? authRepository;
  final CourseRepository? courseRepository;
  final InstructorDashboardRepository? instructorDashboardRepository;

  const AcademicPortalApp({
    super.key,
    this.authRepository,
    this.courseRepository,
    this.instructorDashboardRepository,
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
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final firestore =
        FirebaseConfig.isInitialized ? FirebaseFirestore.instance : null;

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

    _authCubit = AuthCubit(authRepository: _authRepository);
    _themeCubit = ThemeCubit();
    _coursesCubit = CoursesCubit(repository: _courseRepository);
    _courseFormCubit = CourseFormCubit(repository: _courseRepository);
    _instructorDashboardCubit =
        InstructorDashboardCubit(repository: _instructorDashboardRepository);
    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _themeCubit.close();
    _coursesCubit.close();
    _courseFormCubit.close();
    _instructorDashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<InstructorDashboardCubit>.value(
            value: _instructorDashboardCubit),
        BlocProvider<CoursesCubit>.value(value: _coursesCubit),
        BlocProvider<CourseFormCubit>.value(value: _courseFormCubit),
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
    );
  }
}
