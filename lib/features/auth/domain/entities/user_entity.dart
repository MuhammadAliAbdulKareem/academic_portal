import 'package:equatable/equatable.dart';

/// User system roles.
enum UserRole {
  instructor,
  student;

  String get displayName => switch (this) {
        UserRole.instructor => 'Instructor',
        UserRole.student => 'Student',
      };

  bool get isInstructor => this == UserRole.instructor;
  bool get isStudent => this == UserRole.student;
}

/// Core domain representation of an authenticated user.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, role, photoUrl, createdAt];
}
