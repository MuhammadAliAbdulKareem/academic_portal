import 'package:equatable/equatable.dart';

/// Enrollment status lifecycle states.
enum EnrollmentStatus {
  active,
  dropped,
  completed;

  String get displayName => switch (this) {
        EnrollmentStatus.active => 'Active',
        EnrollmentStatus.dropped => 'Dropped',
        EnrollmentStatus.completed => 'Completed',
      };
}

/// Academic course enrollment domain entity.
class EnrollmentEntity extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String instructorName;
  final String department;
  final String term;
  final int credits;
  final String schedule;
  final String room;
  final EnrollmentStatus status;
  final DateTime enrolledAt;
  final String? grade;
  final int completedModules;
  final int totalModules;

  const EnrollmentEntity({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.instructorName,
    required this.department,
    required this.term,
    required this.credits,
    required this.schedule,
    required this.room,
    this.status = EnrollmentStatus.active,
    required this.enrolledAt,
    this.grade,
    this.completedModules = 0,
    this.totalModules = 10,
  });

  bool get isActive => status == EnrollmentStatus.active;

  double get progressRatio =>
      totalModules > 0 ? (completedModules / totalModules).clamp(0.0, 1.0) : 0.0;

  EnrollmentEntity copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? courseCode,
    String? courseTitle,
    String? instructorName,
    String? department,
    String? term,
    int? credits,
    String? schedule,
    String? room,
    EnrollmentStatus? status,
    DateTime? enrolledAt,
    String? grade,
    int? completedModules,
    int? totalModules,
  }) {
    return EnrollmentEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      instructorName: instructorName ?? this.instructorName,
      department: department ?? this.department,
      term: term ?? this.term,
      credits: credits ?? this.credits,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
      status: status ?? this.status,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      grade: grade ?? this.grade,
      completedModules: completedModules ?? this.completedModules,
      totalModules: totalModules ?? this.totalModules,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        courseId,
        courseCode,
        courseTitle,
        instructorName,
        department,
        term,
        credits,
        schedule,
        room,
        status,
        enrolledAt,
        grade,
        completedModules,
        totalModules,
      ];
}

/// Represents a single lecture / lab session in the student daily schedule.
class StudentScheduleItem extends Equatable {
  final String courseCode;
  final String courseTitle;
  final String instructorName;
  final String time;
  final String room;
  final String dayOfWeek;
  final bool isLiveNow;

  const StudentScheduleItem({
    required this.courseCode,
    required this.courseTitle,
    required this.instructorName,
    required this.time,
    required this.room,
    required this.dayOfWeek,
    this.isLiveNow = false,
  });

  @override
  List<Object?> get props => [
        courseCode,
        courseTitle,
        instructorName,
        time,
        room,
        dayOfWeek,
        isLiveNow,
      ];
}

/// Assignment or submission item type.
enum DeadlineType {
  assignment,
  quiz,
  project;

  String get displayName => switch (this) {
        DeadlineType.assignment => 'Assignment',
        DeadlineType.quiz => 'Quiz',
        DeadlineType.project => 'Project',
      };
}

/// Submission status.
enum DeadlineStatus {
  pending,
  submitted,
  graded;

  String get displayName => switch (this) {
        DeadlineStatus.pending => 'Pending',
        DeadlineStatus.submitted => 'Submitted',
        DeadlineStatus.graded => 'Graded',
      };
}

/// Academic task deadline item for enrolled students.
class StudentDeadlineItem extends Equatable {
  final String id;
  final String courseCode;
  final String title;
  final DateTime dueDate;
  final int points;
  final DeadlineType type;
  final DeadlineStatus status;
  final String? earnedGrade;

  const StudentDeadlineItem({
    required this.id,
    required this.courseCode,
    required this.title,
    required this.dueDate,
    required this.points,
    required this.type,
    this.status = DeadlineStatus.pending,
    this.earnedGrade,
  });

  bool get isPending => status == DeadlineStatus.pending;
  bool get isSubmitted => status == DeadlineStatus.submitted;

  @override
  List<Object?> get props => [
        id,
        courseCode,
        title,
        dueDate,
        points,
        type,
        status,
        earnedGrade,
      ];
}

/// High-level academic KPI metrics for the student dashboard.
class StudentDashboardStats extends Equatable {
  final double gpa;
  final int enrolledCredits;
  final int maxCredits;
  final int activeCoursesCount;
  final double attendanceRate;
  final int pendingAssignmentsCount;
  final String academicStanding;

  const StudentDashboardStats({
    required this.gpa,
    required this.enrolledCredits,
    this.maxCredits = 18,
    required this.activeCoursesCount,
    required this.attendanceRate,
    required this.pendingAssignmentsCount,
    this.academicStanding = 'Good Standing (Dean\'s List)',
  });

  double get creditProgress =>
      maxCredits > 0 ? (enrolledCredits / maxCredits).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
        gpa,
        enrolledCredits,
        maxCredits,
        activeCoursesCount,
        attendanceRate,
        pendingAssignmentsCount,
        academicStanding,
      ];
}
