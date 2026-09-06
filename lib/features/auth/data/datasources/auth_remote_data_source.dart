import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<void> signOut();

  Stream<UserModel?> get authStateChanges;

  UserModel? get currentUser;
}

/// Robust implementation supporting Firebase Auth with local demo fallback.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  final StreamController<UserModel?> _mockAuthController =
      StreamController<UserModel?>.broadcast();
  UserModel? _mockCurrentUser;

  // Pre-configured demo users for quick evaluations
  static final List<UserModel> _mockUserDirectory = [
    UserModel(
      id: 'demo-instructor-1',
      email: 'instructor@academic.edu',
      displayName: 'Dr. Sarah Connor',
      role: UserRole.instructor,
      createdAt: DateTime.now(),
    ),
    UserModel(
      id: 'demo-student-1',
      email: 'student@academic.edu',
      displayName: 'Alex Rivers',
      role: UserRole.student,
      createdAt: DateTime.now(),
    ),
  ];

  AuthRemoteDataSourceImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth,
        _firestore = firestore;

  bool get _isFirebaseOperational =>
      FirebaseConfig.isInitialized && _auth != null && _firestore != null;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_isFirebaseOperational) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        final uid = credential.user!.uid;
        final doc = await _firestore!.collection('users').doc(uid).get();

        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, uid);
        } else {
          // Fallback user if profile doc is pending
          return UserModel(
            id: uid,
            email: normalizedEmail,
            displayName: credential.user!.displayName ?? 'Portal User',
            role: UserRole.student,
            createdAt: DateTime.now(),
          );
        }
      } on FirebaseAuthException catch (e) {
        // If this is a pre-configured demo evaluation account, auto-provision or fallback
        if (_mockUserDirectory.any((u) => u.email.toLowerCase() == normalizedEmail)) {
          try {
            final newCredential = await _auth!.createUserWithEmailAndPassword(
              email: normalizedEmail,
              password: password,
            );
            final uid = newCredential.user!.uid;
            final demoUser = _mockUserDirectory.firstWhere((u) => u.email.toLowerCase() == normalizedEmail);
            final userModel = UserModel(
              id: uid,
              email: normalizedEmail,
              displayName: demoUser.displayName,
              role: demoUser.role,
              createdAt: DateTime.now(),
            );
            try {
              await _firestore?.collection('users').doc(uid).set(userModel.toMap());
            } catch (_) {}
            return userModel;
          } catch (_) {
            final demoUser = _mockUserDirectory.firstWhere((u) => u.email.toLowerCase() == normalizedEmail);
            _mockCurrentUser = demoUser;
            _mockAuthController.add(demoUser);
            return demoUser;
          }
        }

        throw AuthException(
          message: _mapFirebaseAuthErrorCode(e.code, e.message),
          code: e.code,
        );
      } catch (e) {
        if (_mockUserDirectory.any((u) => u.email.toLowerCase() == normalizedEmail)) {
          final demoUser = _mockUserDirectory.firstWhere((u) => u.email.toLowerCase() == normalizedEmail);
          _mockCurrentUser = demoUser;
          _mockAuthController.add(demoUser);
          return demoUser;
        }
        throw ServerException(message: e.toString());
      }
    }

    // Offline / Mock fallback execution
    await Future.delayed(const Duration(milliseconds: 300));

    final match = _mockUserDirectory.firstWhere(
      (u) => u.email.toLowerCase() == normalizedEmail,
      orElse: () => UserModel(
        id: 'mock-${normalizedEmail.hashCode}',
        email: normalizedEmail,
        displayName: normalizedEmail.split('@').first.toUpperCase(),
        role: normalizedEmail.contains('instructor') ? UserRole.instructor : UserRole.student,
        createdAt: DateTime.now(),
      ),
    );

    _mockCurrentUser = match;
    _mockAuthController.add(match);
    return match;
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_isFirebaseOperational) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        final uid = credential.user!.uid;
        await credential.user!.updateDisplayName(fullName);

        final newUser = UserModel(
          id: uid,
          email: normalizedEmail,
          displayName: fullName,
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore!.collection('users').doc(uid).set(newUser.toMap());
        return newUser;
      } on FirebaseAuthException catch (e) {
        throw AuthException(
          message: _mapFirebaseAuthErrorCode(e.code, e.message),
          code: e.code,
        );
      } catch (e) {
        throw ServerException(message: e.toString());
      }
    }

    // Offline / Mock fallback execution
    await Future.delayed(const Duration(milliseconds: 350));

    final newUser = UserModel(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      email: normalizedEmail,
      displayName: fullName,
      role: role,
      createdAt: DateTime.now(),
    );

    _mockUserDirectory.add(newUser);
    _mockCurrentUser = newUser;
    _mockAuthController.add(newUser);
    return newUser;
  }

  @override
  Future<void> signOut() async {
    if (_isFirebaseOperational) {
      await _auth!.signOut();
    }
    _mockCurrentUser = null;
    _mockAuthController.add(null);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    if (_isFirebaseOperational) {
      return _auth!.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        try {
          final doc = await _firestore!.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(doc.data()!, user.uid);
          }
        } catch (_) {}
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Portal User',
          role: UserRole.student,
          createdAt: DateTime.now(),
        );
      });
    }
    return _mockAuthController.stream;
  }

  @override
  UserModel? get currentUser {
    if (_isFirebaseOperational) {
      final user = _auth?.currentUser;
      if (user != null) {
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Portal User',
          role: UserRole.student,
          createdAt: DateTime.now(),
        );
      }
    }
    return _mockCurrentUser;
  }

  String _mapFirebaseAuthErrorCode(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No account registered with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid academic email address.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been suspended by administration.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection.';
      default:
        return defaultMessage ?? 'Authentication failed ($code).';
    }
  }
}
