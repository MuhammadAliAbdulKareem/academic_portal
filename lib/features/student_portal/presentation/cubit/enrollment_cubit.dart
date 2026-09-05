import 'package:flutter_bloc/flutter_bloc.dart';
import '../../courses/domain/entities/course_entity.dart';
import '../../domain/repositories/enrollment_repository.dart';
import 'enrollment_state.dart';

/// Cubit managing student course registrations, credit checks, and drop actions.
class EnrollmentCubit extends Cubit<EnrollmentState> {
  final EnrollmentRepository _repository;
  String _currentStudentId = 'demo-student-01';

  EnrollmentCubit({required EnrollmentRepository repository})
      : _repository = repository,
        super(const EnrollmentInitial());

  Future<void> loadEnrollments(String studentId) async {
    _currentStudentId = studentId;
    emit(const EnrollmentLoading());
    try {
      final list = await _repository.getStudentEnrollments(studentId);
      emit(EnrollmentLoaded(enrollments: list));
    } catch (e) {
      emit(EnrollmentError(e.toString()));
    }
  }

  Future<void> enroll({
    required String studentId,
    required CourseEntity course,
  }) async {
    _currentStudentId = studentId;
    final currentState = state;
    final currentList =
        currentState is EnrollmentLoaded ? currentState.enrollments : [];

    // Check if already enrolled
    if (currentState is EnrollmentLoaded && currentState.isEnrolled(course.id)) {
      emit(
        EnrollmentLoaded(
          enrollments: currentState.enrollments,
          message: 'You are already registered in ${course.code}.',
          isActionSuccess: false,
        ),
      );
      return;
    }

    // Check credit hours limit (max 18 credits)
    final currentCredits =
        currentList.fold<int>(0, (sum, item) => sum + item.credits);
    if (currentCredits + course.credits > 18) {
      emit(
        EnrollmentError(
          'Cannot register: Enrolling in ${course.code} (${course.credits} credits) would exceed the maximum limit of 18 credit hours per semester.',
          previousEnrollments: currentList.cast(),
        ),
      );
      return;
    }

    // Check if course is full
    if (course.isFull) {
      emit(
        EnrollmentError(
          'Cannot register: ${course.code} is currently at full capacity (${course.enrolledCount}/${course.maxCapacity}).',
          previousEnrollments: currentList.cast(),
        ),
      );
      return;
    }

    try {
      await _repository.enrollCourse(studentId: studentId, course: course);
      final updatedList = await _repository.getStudentEnrollments(studentId);
      emit(
        EnrollmentLoaded(
          enrollments: updatedList,
          message: 'Successfully enrolled in ${course.code}: ${course.title}!',
          isActionSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        EnrollmentError(
          e.toString(),
          previousEnrollments: currentList.cast(),
        ),
      );
    }
  }

  Future<void> drop({
    required String studentId,
    required String courseId,
  }) async {
    _currentStudentId = studentId;
    final currentState = state;
    final currentList =
        currentState is EnrollmentLoaded ? currentState.enrollments : [];

    try {
      await _repository.dropCourse(studentId: studentId, courseId: courseId);
      final updatedList = await _repository.getStudentEnrollments(studentId);
      emit(
        EnrollmentLoaded(
          enrollments: updatedList,
          message: 'Course offering dropped successfully.',
          isActionSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        EnrollmentError(
          e.toString(),
          previousEnrollments: currentList.cast(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await loadEnrollments(_currentStudentId);
  }
}
