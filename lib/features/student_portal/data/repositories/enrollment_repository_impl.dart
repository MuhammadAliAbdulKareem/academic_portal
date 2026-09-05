import 'package:academic_portal/features/courses/domain/entities/course_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/enrollment_remote_data_source.dart';

/// Concrete repository implementing student enrollment and academic metrics operations.
class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource _remoteDataSource;

  EnrollmentRepositoryImpl({required EnrollmentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<EnrollmentEntity>> getStudentEnrollments(String studentId) async {
    return _remoteDataSource.getEnrollments(studentId);
  }

  @override
  Future<bool> isEnrolled({
    required String studentId,
    required String courseId,
  }) async {
    return _remoteDataSource.isEnrolled(studentId: studentId, courseId: courseId);
  }

  @override
  Future<EnrollmentEntity> enrollCourse({
    required String studentId,
    required CourseEntity course,
  }) async {
    return _remoteDataSource.enrollCourse(studentId: studentId, course: course);
  }

  @override
  Future<void> dropCourse({
    required String studentId,
    required String courseId,
  }) async {
    return _remoteDataSource.dropCourse(studentId: studentId, courseId: courseId);
  }

  @override
  Future<StudentDashboardStats> getStudentDashboardStats(String studentId) async {
    return _remoteDataSource.getStats(studentId);
  }

  @override
  Future<List<StudentScheduleItem>> getTodaySchedule(String studentId) async {
    return _remoteDataSource.getSchedule(studentId);
  }

  @override
  Future<List<StudentDeadlineItem>> getUpcomingDeadlines(String studentId) async {
    return _remoteDataSource.getDeadlines(studentId);
  }

  @override
  Future<void> submitAssignment({
    required String studentId,
    required String deadlineId,
  }) async {
    return _remoteDataSource.submitAssignment(
      studentId: studentId,
      deadlineId: deadlineId,
    );
  }
}
