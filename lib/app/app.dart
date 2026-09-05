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

/// Root application widget configuring global providers, router, and reactive theming.
class AcademicPortalApp extends StatefulWidget {
  final AuthRepository? authRepository;

  const AcademicPortalApp({super.key, this.authRepository});

  @override
  State<AcademicPortalApp> createState() => _AcademicPortalAppState();
}

class _AcademicPortalAppState extends State<AcademicPortalApp> {
  late final AuthRepository _authRepository;
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ??
        AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(
            auth: FirebaseConfig.isInitialized ? FirebaseAuth.instance : null,
            firestore: FirebaseConfig.isInitialized ? FirebaseFirestore.instance : null,
          ),
        );

    _authCubit = AuthCubit(authRepository: _authRepository);
    _themeCubit = ThemeCubit();
    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<AuthCubit>.value(value: _authCubit),
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
