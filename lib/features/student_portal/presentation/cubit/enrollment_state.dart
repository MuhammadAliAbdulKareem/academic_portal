import 'package:equatable/equatable.dart';
import '../../domain/entities/enrollment_entity.dart';

abstract class EnrollmentState extends Equatable {
  const EnrollmentState();

  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {
  const EnrollmentInitial();
}

class EnrollmentLoading extends EnrollmentState {
  const EnrollmentLoading();
}

class EnrollmentLoaded extends EnrollmentState {
  final List<EnrollmentEntity> enrollments;
  final String? message;
  final bool isActionSuccess;

  const EnrollmentLoaded({
    required this.enrollments,
    this.message,
    this.isActionSuccess = false,
  });

  int get totalCredits =>
      enrollments.fold<int>(0, (sum, item) => sum + item.credits);

  bool isEnrolled(String courseId) =>
      enrollments.any((e) => e.courseId == courseId && e.isActive);

  EnrollmentLoaded copyWith({
    List<EnrollmentEntity>? enrollments,
    String? message,
    bool? isActionSuccess,
  }) {
    return EnrollmentLoaded(
      enrollments: enrollments ?? this.enrollments,
      message: message ?? this.message,
      isActionSuccess: isActionSuccess ?? this.isActionSuccess,
    );
  }

  @override
  List<Object?> get props => [enrollments, message, isActionSuccess];
}

class EnrollmentError extends EnrollmentState {
  final String message;
  final List<EnrollmentEntity> previousEnrollments;

  const EnrollmentError(this.message, {this.previousEnrollments = const []});

  @override
  List<Object?> get props => [message, previousEnrollments];
}
