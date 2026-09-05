import 'package:equatable/equatable.dart';

/// Key performance indicators for an instructor.
class InstructorDashboardStats extends Equatable {
  final int activeCourses;
  final int totalStudents;
  final int pendingGrading;
  final double attendanceRate;

  const InstructorDashboardStats({
    required this.activeCourses,
    required this.totalStudents,
    required this.pendingGrading,
    required this.attendanceRate,
  });

  @override
  List<Object?> get props => [
        activeCourses,
        totalStudents,
        pendingGrading,
        attendanceRate,
      ];
}

/// Brief overview of an instructor's course.
class CourseSummaryEntity extends Equatable {
  final String id;
  final String code;
  final String title;
  final String term;
  final int enrolledCount;
  final String schedule;
  final String room;
  final String department;

  const CourseSummaryEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.term,
    required this.enrolledCount,
    required this.schedule,
    required this.room,
    required this.department,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        term,
        enrolledCount,
        schedule,
        room,
        department,
      ];
}

/// Recent student or system event in the instructor's courses.
class RecentActivityEntity extends Equatable {
  final String id;
  final String studentName;
  final String courseCode;
  final String activityDescription;
  final DateTime timestamp;
  final String type; // 'submission', 'enrollment', 'question'

  const RecentActivityEntity({
    required this.id,
    required this.studentName,
    required this.courseCode,
    required this.activityDescription,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        studentName,
        courseCode,
        activityDescription,
        timestamp,
        type,
      ];
}

/// Upcoming assignment or exam deadline with grading progress.
class UpcomingDeadlineEntity extends Equatable {
  final String id;
  final String title;
  final String courseCode;
  final DateTime dueDate;
  final int submittedCount;
  final int totalExpected;

  const UpcomingDeadlineEntity({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.dueDate,
    required this.submittedCount,
    required this.totalExpected,
  });

  double get completionRatio =>
      totalExpected > 0 ? (submittedCount / totalExpected).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
        id,
        title,
        courseCode,
        dueDate,
        submittedCount,
        totalExpected,
      ];
}
