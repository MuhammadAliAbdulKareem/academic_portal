import 'package:equatable/equatable.dart';

/// Base class for all domain failure models.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Generic server or backend failure.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network connectivity failure.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Authentication and authorization failure.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Firebase/Firestore failure.
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}
