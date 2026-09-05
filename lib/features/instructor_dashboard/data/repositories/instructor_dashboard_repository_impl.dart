import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/instructor_dashboard_repository.dart';
import '../datasources/instructor_dashboard_remote_data_source.dart';

/// Concrete repository connecting domain operations to remote data source.
class InstructorDashboardRepositoryImpl
    implements InstructorDashboardRepository {
  final InstructorDashboardRemoteDataSource _remoteDataSource;

  InstructorDashboardRepositoryImpl({
    required InstructorDashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<InstructorDashboardStats> getStats(String instructorId) async {
    return await _remoteDataSource.getStats(instructorId);
  }

  @override
  Future<List<CourseSummaryEntity>> getCourses(String instructorId) async {
    return await _remoteDataSource.getCourses(instructorId);
  }

  @override
  Future<List<RecentActivityEntity>> getRecentActivities(
      String instructorId) async {
    return await _remoteDataSource.getRecentActivities(instructorId);
  }

  @override
  Future<List<UpcomingDeadlineEntity>> getUpcomingDeadlines(
      String instructorId) async {
    return await _remoteDataSource.getUpcomingDeadlines(instructorId);
  }
}
