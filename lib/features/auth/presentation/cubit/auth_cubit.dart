import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit orchestrating user authentication transactions and session tracking.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    final current = _authRepository.currentUser;
    if (current != null) {
      emit(Authenticated(current));
    } else {
      emit(const Unauthenticated());
    }

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  /// Authenticates user with email and password credentials.
  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Registers a new user account and creates their profile.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Signs the user out of the application.
  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
