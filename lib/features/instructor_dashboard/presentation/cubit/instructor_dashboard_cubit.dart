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
      final results = await Future.wait([
        _repository.getStats(instructorId),
        _repository.getCourses(instructorId),
        _repository.getRecentActivities(instructorId),
        _repository.getUpcomingDeadlines(instructorId),
      ]);

      emit(
        InstructorDashboardLoaded(
          stats: results[0] as dynamic,
          courses: results[1] as dynamic,
          activities: results[2] as dynamic,
          deadlines: results[3] as dynamic,
        ),
      );
    } catch (e) {
      emit(InstructorDashboardError(e.toString()));
    }
  }

  Future<void> refreshDashboard(String instructorId) async {
    try {
      final results = await Future.wait([
        _repository.getStats(instructorId),
        _repository.getCourses(instructorId),
        _repository.getRecentActivities(instructorId),
        _repository.getUpcomingDeadlines(instructorId),
      ]);

      emit(
        InstructorDashboardLoaded(
          stats: results[0] as dynamic,
          courses: results[1] as dynamic,
          activities: results[2] as dynamic,
          deadlines: results[3] as dynamic,
        ),
      );
    } catch (e) {
      emit(InstructorDashboardError(e.toString()));
    }
  }
}
