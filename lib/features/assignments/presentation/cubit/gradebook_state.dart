import 'package:equatable/equatable.dart';
import '../../domain/entities/assignment_entity.dart';

abstract class GradebookState extends Equatable {
  const GradebookState();

  @override
  List<Object?> get props => [];
}

class GradebookInitial extends GradebookState {
  const GradebookInitial();
}

class GradebookLoading extends GradebookState {
  const GradebookLoading();
}

class GradebookLoaded extends GradebookState {
  final CourseGradebook gradebook;

  const GradebookLoaded(this.gradebook);

  @override
  List<Object?> get props => [gradebook];
}

class GradebookError extends GradebookState {
  final String message;

  const GradebookError(this.message);

  @override
  List<Object?> get props => [message];
}
