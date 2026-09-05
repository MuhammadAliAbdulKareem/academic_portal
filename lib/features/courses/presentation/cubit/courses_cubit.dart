import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/course_repository.dart';
import 'courses_state.dart';

/// Cubit managing catalog listing, department filters, search, and details.
class CoursesCubit extends Cubit<CoursesState> {
  final CourseRepository _repository;
  String _currentDepartment = 'All';
  String _currentSearch = '';
  String? _currentInstructorId;

  CoursesCubit({required CourseRepository repository})
      : _repository = repository,
        super(const CoursesInitial());

  Future<void> loadCourses({
    String? instructorId,
    String department = 'All',
    String searchQuery = '',
  }) async {
    _currentInstructorId = instructorId;
    _currentDepartment = department;
    _currentSearch = searchQuery;

    emit(const CoursesLoading());
    try {
      final list = await _repository.getCourses(
        instructorId: instructorId,
        department: department == 'All' ? null : department,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
      );

      emit(
        CoursesLoaded(
          courses: list,
          selectedDepartment: department,
          searchQuery: searchQuery,
        ),
      );
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> filterByDepartment(String department) async {
    _currentDepartment = department;
    await loadCourses(
      instructorId: _currentInstructorId,
      department: _currentDepartment,
      searchQuery: _currentSearch,
    );
  }

  Future<void> search(String query) async {
    _currentSearch = query;
    await loadCourses(
      instructorId: _currentInstructorId,
      department: _currentDepartment,
      searchQuery: _currentSearch,
    );
  }

  Future<void> loadCourseDetails(String courseId) async {
    final currentState = state;
    try {
      final course = await _repository.getCourseById(courseId);
      if (currentState is CoursesLoaded) {
        emit(currentState.copyWith(selectedCourse: course));
      } else {
        emit(
          CoursesLoaded(
            courses: [course],
            selectedCourse: course,
          ),
        );
      }
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadCourses(
      instructorId: _currentInstructorId,
      department: _currentDepartment,
      searchQuery: _currentSearch,
    );
  }
}
