import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/instructor_dashboard_repository.dart';
import 'instructor_dashboard_state.dart';

/// Cubit managing instructor metrics, course rosters, and live activity streams.
class InstructorDashboardCubit extends Cubit<InstructorDashboardState> {
  final InstructorDashboardRepository _repository;

  InstructorDashboardCubit({
    required InstructorDashboardRepository repository,
  })  : _repository = repository,
        super(const InstructorDashboardInitial());

  Future<void> loadDashboard(String instructorId) async {
    emit(const InstructorDashboardLoading());
    try {
      final stats = await _repository.getStats(instructorId);
      final courses = await _repository.getCourses(instructorId);
      final activities = await _repository.getRecentActivities(instructorId);
      final deadlines = await _repository.getUpcomingDeadlines(instructorId);

      emit(
        InstructorDashboardLoaded(
          stats: stats,
          courses: courses,
          activities: activities,
          deadlines: deadlines,
        ),
      );
    } catch (e) {
      emit(InstructorDashboardError(e.toString()));
    }
  }

  Future<void> refreshDashboard(String instructorId) async {
    try {
      final stats = await _repository.getStats(instructorId);
      final courses = await _repository.getCourses(instructorId);
      final activities = await _repository.getRecentActivities(instructorId);
      final deadlines = await _repository.getUpcomingDeadlines(instructorId);

      emit(
        InstructorDashboardLoaded(
          stats: stats,
          courses: courses,
          activities: activities,
          deadlines: deadlines,
        ),
      );
    } catch (e) {
      emit(InstructorDashboardError(e.toString()));
    }
  }
}
