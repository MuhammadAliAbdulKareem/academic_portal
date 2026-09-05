import '../entities/user_entity.dart';

/// Contract defining authentication operations for the application.
abstract class AuthRepository {
  /// Signs in an existing user with email and password.
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new user with email, password, full name, and selected role.
  Future<UserEntity> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  /// Terminates the active authenticated user session.
  Future<void> signOut();

  /// Stream emitting real-time authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Retrieves the currently cached or active user session, if any.
  UserEntity? get currentUser;
}
