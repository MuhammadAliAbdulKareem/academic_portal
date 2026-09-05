import 'package:academic_portal/features/courses/domain/entities/course_entity.dart';
import '../entities/enrollment_entity.dart';

/// Contract interface for student enrollment and academic dashboard data.
abstract class EnrollmentRepository {
  /// Fetches all enrollments for a given student.
  Future<List<EnrollmentEntity>> getStudentEnrollments(String studentId);

  /// Checks if a student is actively enrolled in a specific course.
  Future<bool> isEnrolled({
    required String studentId,
    required String courseId,
  });

  /// Enrolls a student in a course offering.
  Future<EnrollmentEntity> enrollCourse({
    required String studentId,
    required CourseEntity course,
  });

  /// Drops an active course enrollment.
  Future<void> dropCourse({
    required String studentId,
    required String courseId,
  });

  /// Retrieves aggregate student academic statistics.
  Future<StudentDashboardStats> getStudentDashboardStats(String studentId);

  /// Retrieves today's timetable sessions for the student.
  Future<List<StudentScheduleItem>> getTodaySchedule(String studentId);

  /// Retrieves upcoming assignment and project deadlines.
  Future<List<StudentDeadlineItem>> getUpcomingDeadlines(String studentId);

  /// Marks a deadline task as submitted by the student.
  Future<void> submitAssignment({
    required String studentId,
    required String deadlineId,
  });
}
