import 'package:equatable/equatable.dart';
import '../../domain/entities/assignment_entity.dart';

abstract class AssignmentDetailState extends Equatable {
  const AssignmentDetailState();

  @override
  List<Object?> get props => [];
}

class AssignmentDetailInitial extends AssignmentDetailState {
  const AssignmentDetailInitial();
}

class AssignmentDetailLoading extends AssignmentDetailState {
  const AssignmentDetailLoading();
}

class AssignmentDetailLoaded extends AssignmentDetailState {
  final AssignmentEntity assignment;
  final SubmissionEntity? studentSubmission;
  final List<SubmissionEntity> allSubmissions;

  const AssignmentDetailLoaded({
    required this.assignment,
    this.studentSubmission,
    this.allSubmissions = const [],
  });

  bool get hasSubmitted => studentSubmission != null;
  bool get isGraded => studentSubmission?.isGraded ?? false;

  AssignmentDetailLoaded copyWith({
    AssignmentEntity? assignment,
    SubmissionEntity? studentSubmission,
    List<SubmissionEntity>? allSubmissions,
  }) {
    return AssignmentDetailLoaded(
      assignment: assignment ?? this.assignment,
      studentSubmission: studentSubmission ?? this.studentSubmission,
      allSubmissions: allSubmissions ?? this.allSubmissions,
    );
  }

  @override
  List<Object?> get props => [assignment, studentSubmission, allSubmissions];
}

class AssignmentDetailError extends AssignmentDetailState {
  final String message;

  const AssignmentDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
