import 'package:equatable/equatable.dart';
import '../../domain/entities/course_entity.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

class CoursesLoaded extends CoursesState {
  final List<CourseEntity> courses;
  final String selectedDepartment;
  final String searchQuery;
  final CourseEntity? selectedCourse;

  const CoursesLoaded({
    required this.courses,
    this.selectedDepartment = 'All',
    this.searchQuery = '',
    this.selectedCourse,
  });

  CoursesLoaded copyWith({
    List<CourseEntity>? courses,
    String? selectedDepartment,
    String? searchQuery,
    CourseEntity? selectedCourse,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourse: selectedCourse ?? this.selectedCourse,
    );
  }

  @override
  List<Object?> get props => [courses, selectedDepartment, searchQuery, selectedCourse];
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
