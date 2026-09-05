import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class StudentAttendanceHistoryState extends Equatable {
  const StudentAttendanceHistoryState();

  @override
  List<Object?> get props => [];
}

class StudentAttendanceHistoryInitial extends StudentAttendanceHistoryState {
  const StudentAttendanceHistoryInitial();
}

class StudentAttendanceHistoryLoading extends StudentAttendanceHistoryState {
  const StudentAttendanceHistoryLoading();
}

class StudentAttendanceHistoryLoaded extends StudentAttendanceHistoryState {
  final List<AttendanceRecordEntity> allRecords;
  final List<AttendanceRecordEntity> filteredRecords;
  final List<StudentAttendanceSummaryEntity> courseSummaries;
  final String? selectedCourseFilter;

  const StudentAttendanceHistoryLoaded({
    required this.allRecords,
    required this.filteredRecords,
    required this.courseSummaries,
    this.selectedCourseFilter,
  });

  /// Calculates cumulative attendance percentage across all courses
  double get overallAttendanceRate {
    if (allRecords.isEmpty) return 100.0;
    final attended = allRecords.where(
      (r) =>
          r.status == AttendanceStatus.present ||
          r.status == AttendanceStatus.late,
    ).length;
    return (attended / allRecords.length) * 100.0;
  }

  int get totalPresent =>
      allRecords.where((r) => r.status == AttendanceStatus.present).length;
  int get totalLate =>
      allRecords.where((r) => r.status == AttendanceStatus.late).length;
  int get totalAbsent =>
      allRecords.where((r) => r.status == AttendanceStatus.absent).length;
  int get totalExcused =>
      allRecords.where((r) => r.status == AttendanceStatus.excused).length;

  StudentAttendanceHistoryLoaded copyWith({
    List<AttendanceRecordEntity>? allRecords,
    List<AttendanceRecordEntity>? filteredRecords,
    List<StudentAttendanceSummaryEntity>? courseSummaries,
    String? selectedCourseFilter,
    bool clearCourseFilter = false,
  }) {
    return StudentAttendanceHistoryLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      courseSummaries: courseSummaries ?? this.courseSummaries,
      selectedCourseFilter: clearCourseFilter
          ? null
          : (selectedCourseFilter ?? this.selectedCourseFilter),
    );
  }

  @override
  List<Object?> get props => [
        allRecords,
        filteredRecords,
        courseSummaries,
        selectedCourseFilter,
      ];
}

class StudentAttendanceHistoryError extends StudentAttendanceHistoryState {
  final String message;
  const StudentAttendanceHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
