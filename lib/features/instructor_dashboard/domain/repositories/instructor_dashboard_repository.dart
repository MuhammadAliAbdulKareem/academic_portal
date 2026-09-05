import '../entities/dashboard_entities.dart';

/// Contract for fetching instructor dashboard statistics and academic course overviews.
abstract class InstructorDashboardRepository {
  Future<InstructorDashboardStats> getStats(String instructorId);

  Future<List<CourseSummaryEntity>> getCourses(String instructorId);

  Future<List<RecentActivityEntity>> getRecentActivities(String instructorId);

  Future<List<UpcomingDeadlineEntity>> getUpcomingDeadlines(String instructorId);
}
