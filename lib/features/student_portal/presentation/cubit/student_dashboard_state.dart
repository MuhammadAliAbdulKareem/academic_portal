import 'package:equatable/equatable.dart';
import '../../domain/entities/enrollment_entity.dart';

abstract class StudentDashboardState extends Equatable {
  const StudentDashboardState();

  @override
  List<Object?> get props => [];
}

class StudentDashboardInitial extends StudentDashboardState {
  const StudentDashboardInitial();
}

class StudentDashboardLoading extends StudentDashboardState {
  const StudentDashboardLoading();
}

class StudentDashboardLoaded extends StudentDashboardState {
  final StudentDashboardStats stats;
  final List<StudentScheduleItem> todaySchedule;
  final List<EnrollmentEntity> enrolledCourses;
  final List<StudentDeadlineItem> upcomingDeadlines;

  const StudentDashboardLoaded({
    required this.stats,
    required this.todaySchedule,
    required this.enrolledCourses,
    required this.upcomingDeadlines,
  });

  StudentDashboardLoaded copyWith({
    StudentDashboardStats? stats,
    List<StudentScheduleItem>? todaySchedule,
    List<EnrollmentEntity>? enrolledCourses,
    List<StudentDeadlineItem>? upcomingDeadlines,
  }) {
    return StudentDashboardLoaded(
      stats: stats ?? this.stats,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      upcomingDeadlines: upcomingDeadlines ?? this.upcomingDeadlines,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        todaySchedule,
        enrolledCourses,
        upcomingDeadlines,
      ];
}

class StudentDashboardError extends StudentDashboardState {
  final String message;

  const StudentDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
