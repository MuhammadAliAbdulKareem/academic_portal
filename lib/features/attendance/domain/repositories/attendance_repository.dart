import '../entities/attendance_entity.dart';

/// Abstract contract for attendance session management, check-in operations,
/// and student attendance history tracking.
abstract class AttendanceRepository {
  /// Retrieves all attendance sessions for a specific course.
  Future<List<AttendanceSessionEntity>> getCourseSessions(String courseId);

  /// Retrieves the currently active attendance session for a course, if one is open.
  Future<AttendanceSessionEntity?> getActiveSession(String courseId);

  /// Starts a new live attendance session with an automated QR token and 6-digit PIN.
  Future<AttendanceSessionEntity> startAttendanceSession({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required String section,
    required String title,
    required String room,
    required int durationMinutes,
  });

  /// Closes an active attendance session and marks absent students.
  Future<AttendanceSessionEntity> endAttendanceSession(String sessionId);

  /// Retrieves all student records for a specific session roster.
  Future<List<AttendanceRecordEntity>> getSessionRecords(String sessionId);

  /// Performs a student check-in using a dynamic QR verification token or 6-digit PIN.
  Future<AttendanceRecordEntity> checkInStudent({
    required String sessionId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    required CheckInMethod method,
    required String pinOrToken,
  });

  /// Updates an individual student's attendance record (e.g. manual faculty override).
  Future<AttendanceRecordEntity> updateStudentRecordStatus({
    required String recordId,
    required AttendanceStatus newStatus,
    String? notes,
  });

  /// Retrieves personal attendance records for a student across all or specific courses.
  Future<List<AttendanceRecordEntity>> getStudentAttendanceHistory({
    required String studentId,
    String? courseId,
  });

  /// Calculates or retrieves an aggregated attendance summary for a student in a course.
  Future<StudentAttendanceSummaryEntity> getStudentAttendanceSummary({
    required String studentId,
    required String courseId,
  });

  /// Retrieves attendance summaries for all enrolled students in a course.
  Future<List<StudentAttendanceSummaryEntity>> getAllStudentSummariesForCourse(
    String courseId,
  );
}
