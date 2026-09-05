import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'student_attendance_history_state.dart';

class StudentAttendanceHistoryCubit extends Cubit<StudentAttendanceHistoryState> {
  final AttendanceRepository repository;

  StudentAttendanceHistoryCubit({required this.repository})
      : super(const StudentAttendanceHistoryInitial());

  Future<void> loadHistory({
    required String studentId,
    String? courseId,
  }) async {
    emit(const StudentAttendanceHistoryLoading());
    try {
      final records = await repository.getStudentAttendanceHistory(
        studentId: studentId,
      );

      // Collect unique course IDs from records
      final courseIds = records.map((r) => r.courseId).toSet().toList();
      if (courseIds.isEmpty) {
        courseIds.addAll(['course-cs101', 'course-cs201', 'course-math301']);
      }

      final summaries = <StudentAttendanceSummaryEntity>[];
      for (final cid in courseIds) {
        final summary = await repository.getStudentAttendanceSummary(
          studentId: studentId,
          courseId: cid,
        );
        summaries.add(summary);
      }

      final filtered = (courseId != null && courseId.isNotEmpty)
          ? records.where((r) => r.courseId == courseId).toList()
          : records;

      emit(
        StudentAttendanceHistoryLoaded(
          allRecords: records,
          filteredRecords: filtered,
          courseSummaries: summaries,
          selectedCourseFilter: courseId,
        ),
      );
    } catch (e) {
      emit(StudentAttendanceHistoryError('Failed to load history: ${e.toString()}'));
    }
  }

  void filterByCourse(String? courseId) {
    if (state is! StudentAttendanceHistoryLoaded) return;
    final current = state as StudentAttendanceHistoryLoaded;

    final filtered = (courseId != null && courseId.isNotEmpty)
        ? current.allRecords.where((r) => r.courseId == courseId).toList()
        : current.allRecords;

    emit(
      current.copyWith(
        selectedCourseFilter: courseId,
        clearCourseFilter: courseId == null || courseId.isEmpty,
        filteredRecords: filtered,
      ),
    );
  }
}
