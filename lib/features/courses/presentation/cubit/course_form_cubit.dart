import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import 'course_form_state.dart';

/// Cubit managing validation, module additions, and submission for courses.
class CourseFormCubit extends Cubit<CourseFormState> {
  final CourseRepository _repository;

  CourseFormCubit({required CourseRepository repository})
      : _repository = repository,
        super(const CourseFormInitial());

  Future<void> submitCourse({
    required String code,
    required String title,
    required String description,
    required String instructorId,
    required String instructorName,
    required String term,
    required String department,
    required int credits,
    required String schedule,
    required String room,
    required int maxCapacity,
    required List<SyllabusItem> syllabus,
  }) async {
    emit(const CourseFormSubmitting());

    try {
      final course = CourseEntity(
        id: '',
        code: code.trim(),
        title: title.trim(),
        description: description.trim(),
        instructorId: instructorId,
        instructorName: instructorName,
        term: term,
        department: department,
        credits: credits,
        schedule: schedule.trim(),
        room: room.trim(),
        enrolledCount: 0,
        maxCapacity: maxCapacity,
        syllabus: syllabus,
        createdAt: DateTime.now(),
      );

      final result = await _repository.createCourse(course);
      emit(CourseFormSuccess(result));
    } catch (e) {
      emit(CourseFormFailure(e.toString()));
    }
  }

  void reset() {
    emit(const CourseFormInitial());
  }
}
