import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_entities.dart';

abstract class InstructorDashboardState extends Equatable {
  const InstructorDashboardState();

  @override
  List<Object?> get props => [];
}

class InstructorDashboardInitial extends InstructorDashboardState {
  const InstructorDashboardInitial();
}

class InstructorDashboardLoading extends InstructorDashboardState {
  const InstructorDashboardLoading();
}

class InstructorDashboardLoaded extends InstructorDashboardState {
  final InstructorDashboardStats stats;
  final List<CourseSummaryEntity> courses;
  final List<RecentActivityEntity> activities;
  final List<UpcomingDeadlineEntity> deadlines;

  const InstructorDashboardLoaded({
    required this.stats,
    required this.courses,
    required this.activities,
    required this.deadlines,
  });

  @override
  List<Object?> get props => [stats, courses, activities, deadlines];
}

class InstructorDashboardError extends InstructorDashboardState {
  final String message;

  const InstructorDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
