import 'package:equatable/equatable.dart';
import '../../domain/entities/assignment_entity.dart';

abstract class SubmissionState extends Equatable {
  const SubmissionState();

  @override
  List<Object?> get props => [];
}

class SubmissionInitial extends SubmissionState {
  const SubmissionInitial();
}

class SubmissionSubmitting extends SubmissionState {
  final double progress;

  const SubmissionSubmitting({this.progress = 0.5});

  @override
  List<Object?> get props => [progress];
}

class SubmissionSuccess extends SubmissionState {
  final SubmissionEntity submission;

  const SubmissionSuccess(this.submission);

  @override
  List<Object?> get props => [submission];
}

class SubmissionFailure extends SubmissionState {
  final String message;

  const SubmissionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
