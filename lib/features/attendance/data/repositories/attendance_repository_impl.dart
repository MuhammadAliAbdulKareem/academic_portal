import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  AttendanceRepositoryImpl({required AttendanceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AttendanceSessionEntity>> getCourseSessions(String courseId) async {
    try {
      return await _remoteDataSource.getCourseSessions(courseId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AttendanceSessionEntity?> getActiveSession(String courseId) async {
    try {
      return await _remoteDataSource.getActiveSession(courseId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AttendanceSessionEntity> startAttendanceSession({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required String section,
    required String title,
    required String room,
    required int durationMinutes,
  }) async {
    try {
      return await _remoteDataSource.startAttendanceSession(
        courseId: courseId,
        courseCode: courseCode,
        courseTitle: courseTitle,
        section: section,
        title: title,
        room: room,
        durationMinutes: durationMinutes,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AttendanceSessionEntity> endAttendanceSession(String sessionId) async {
    try {
      return await _remoteDataSource.endAttendanceSession(sessionId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AttendanceRecordEntity>> getSessionRecords(String sessionId) async {
    try {
      return await _remoteDataSource.getSessionRecords(sessionId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AttendanceRecordEntity> checkInStudent({
    required String sessionId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    required CheckInMethod method,
    required String pinOrToken,
  }) async {
    try {
      return await _remoteDataSource.checkInStudent(
        sessionId: sessionId,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        studentAvatar: studentAvatar,
        method: method,
        pinOrToken: pinOrToken,
      );
    } catch (e) {
      throw ServerException(message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AttendanceRecordEntity> updateStudentRecordStatus({
    required String recordId,
    required AttendanceStatus newStatus,
    String? notes,
  }) async {
    try {
      return await _remoteDataSource.updateStudentRecordStatus(
        recordId: recordId,
        newStatus: newStatus,
        notes: notes,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AttendanceRecordEntity>> getStudentAttendanceHistory({
    required String studentId,
    String? courseId,
  }) async {
    try {
      return await _remoteDataSource.getStudentAttendanceHistory(
        studentId: studentId,
        courseId: courseId,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StudentAttendanceSummaryEntity> getStudentAttendanceSummary({
    required String studentId,
    required String courseId,
  }) async {
    try {
      return await _remoteDataSource.getStudentAttendanceSummary(
        studentId: studentId,
        courseId: courseId,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StudentAttendanceSummaryEntity>> getAllStudentSummariesForCourse(
    String courseId,
  ) async {
    try {
      return await _remoteDataSource.getAllStudentSummariesForCourse(courseId);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
