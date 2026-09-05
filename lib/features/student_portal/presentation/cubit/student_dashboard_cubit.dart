import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/enrollment_repository.dart';
import 'student_dashboard_state.dart';

/// Cubit managing student academic analytics, timetable, courses, and deadlines.
class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  final EnrollmentRepository _repository;
  String? _lastStudentId;

  StudentDashboardCubit({required EnrollmentRepository repository})
      : _repository = repository,
        super(const StudentDashboardInitial());

  Future<void> loadDashboard(String studentId) async {
    _lastStudentId = studentId;
    emit(const StudentDashboardLoading());
    try {
      final results = await Future.wait([
        _repository.getStudentDashboardStats(studentId),
        _repository.getTodaySchedule(studentId),
        _repository.getStudentEnrollments(studentId),
        _repository.getUpcomingDeadlines(studentId),
      ]);

      emit(
        StudentDashboardLoaded(
          stats: results[0] as dynamic,
          todaySchedule: results[1] as dynamic,
          enrolledCourses: results[2] as dynamic,
          upcomingDeadlines: results[3] as dynamic,
        ),
      );
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }

  Future<void> refreshDashboard([String? studentId]) async {
    final id = studentId ?? _lastStudentId ?? 'demo-student-01';
    await loadDashboard(id);
  }

  Future<void> submitAssignment({
    required String studentId,
    required String deadlineId,
  }) async {
    try {
      await _repository.submitAssignment(
        studentId: studentId,
        deadlineId: deadlineId,
      );
      final updatedDeadlines = await _repository.getUpcomingDeadlines(studentId);
      final updatedStats = await _repository.getStudentDashboardStats(studentId);

      final currentState = state;
      if (currentState is StudentDashboardLoaded) {
        emit(
          currentState.copyWith(
            stats: updatedStats,
            upcomingDeadlines: updatedDeadlines,
          ),
        );
      }
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }
}
