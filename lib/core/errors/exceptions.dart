/// Base application exception.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Thrown when server communication fails.
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Thrown when network connection is absent.
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

/// Thrown on auth errors.
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Thrown on database/cache errors.
class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code});
}
