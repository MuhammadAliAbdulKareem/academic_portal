import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:academic_portal/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:academic_portal/features/auth/data/models/user_model.dart';
import 'package:academic_portal/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:academic_portal/features/auth/domain/entities/user_entity.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_state.dart';
import 'package:academic_portal/features/auth/presentation/screens/login_screen.dart';
import 'package:academic_portal/features/auth/presentation/screens/register_screen.dart';

void main() {
  group('Authentication Unit Tests', () {
    test('UserModel serializes and deserializes correctly', () {
      final now = DateTime(2026, 9, 5, 12, 0);
      final user = UserModel(
        id: 'u-123',
        email: 'prof.smith@academic.edu',
        displayName: 'Professor Smith',
        role: UserRole.instructor,
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['email'], 'prof.smith@academic.edu');
      expect(map['role'], 'instructor');

      final deserialized = UserModel.fromMap(map, 'u-123');
      expect(deserialized.id, 'u-123');
      expect(deserialized.role, UserRole.instructor);
      expect(deserialized.displayName, 'Professor Smith');
    });

    test('AuthCubit performs login, registration, and logout flows', () async {
      final mockDataSource = AuthRemoteDataSourceImpl();
      final repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
      final authCubit = AuthCubit(authRepository: repository);

      // Verify registration
      await authCubit.register(
        email: 'new.instructor@academic.edu',
        password: 'Password123!',
        fullName: 'Dr. John Watson',
        role: UserRole.instructor,
      );

      expect(authCubit.state, isA<Authenticated>());
      final authState = authCubit.state as Authenticated;
      expect(authState.user.email, 'new.instructor@academic.edu');
      expect(authState.user.role, UserRole.instructor);

      // Verify logout
      await authCubit.logout();
      expect(authCubit.state, isA<Unauthenticated>());

      // Verify login with demo user
      await authCubit.login(
        email: 'student@academic.edu',
        password: 'Student123!',
      );

      expect(authCubit.state, isA<Authenticated>());
      final studentState = authCubit.state as Authenticated;
      expect(studentState.user.role, UserRole.student);

      await authCubit.close();
    });
  });

  group('Authentication Widget Tests', () {
    testWidgets('LoginScreen renders inputs, demo shortcuts, and validates empty email',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockDataSource = AuthRemoteDataSourceImpl();
      final repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
      final authCubit = AuthCubit(authRepository: repository);

      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home Page')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Academic Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Instructor'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);

      // Scroll to submit button and attempt submit with empty fields
      await tester.ensureVisible(find.text('Sign In to Portal'));
      await tester.tap(find.text('Sign In to Portal'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);

      // Tap demo instructor shortcut
      await tester.tap(find.text('Instructor'));
      await tester.pump();

      // Submit valid demo login
      await tester.ensureVisible(find.text('Sign In to Portal'));
      await tester.tap(find.text('Sign In to Portal'));
      await tester.pumpAndSettle();

      expect(authCubit.state, isA<Authenticated>());
      expect(find.text('Home Page'), findsOneWidget);

      await authCubit.close();
    });

    testWidgets('RegisterScreen toggles roles and renders required form inputs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockDataSource = AuthRemoteDataSourceImpl();
      final repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
      final authCubit = AuthCubit(authRepository: repository);

      final router = GoRouter(
        initialLocation: '/register',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home Page')),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('Create Portal Account'), findsOneWidget);
      expect(find.text('SELECT YOUR ACADEMIC ROLE'), findsOneWidget);
      expect(find.text('Full Name & Title'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Switch role to instructor
      await tester.tap(find.text('Instructor'));
      await tester.pump();

      await authCubit.close();
    });
  });
}
