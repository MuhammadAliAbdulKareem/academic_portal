import 'package:equatable/equatable.dart';
import '../../domain/entities/course_entity.dart';

abstract class CourseFormState extends Equatable {
  const CourseFormState();

  @override
  List<Object?> get props => [];
}

class CourseFormInitial extends CourseFormState {
  const CourseFormInitial();
}

class CourseFormSubmitting extends CourseFormState {
  const CourseFormSubmitting();
}

class CourseFormSuccess extends CourseFormState {
  final CourseEntity course;

  const CourseFormSuccess(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseFormFailure extends CourseFormState {
  final String error;

  const CourseFormFailure(this.error);

  @override
  List<Object?> get props => [error];
}
