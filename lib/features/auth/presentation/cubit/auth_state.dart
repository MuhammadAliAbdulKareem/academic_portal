import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Processing authentication transaction.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Successfully authenticated with active user session.
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No active user session.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error encountered during authentication flow.
class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
