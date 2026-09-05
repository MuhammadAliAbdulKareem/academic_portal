import 'package:equatable/equatable.dart';

/// Status of an academic assignment.
enum AssignmentStatus {
  upcoming,
  open,
  closed,
}

/// Allowed submission method for an assignment.
enum SubmissionType {
  fileUpload,
  textEntry,
  both,
}

/// Evaluation status of a student submission.
enum SubmissionStatus {
  pending,
  submitted,
  graded,
  late,
}

/// Level within a rubric criterion (e.g. Exemplary, Proficient).
class RubricLevel extends Equatable {
  final String id;
  final String title;
  final double points;
  final String description;

  const RubricLevel({
    required this.id,
    required this.title,
    required this.points,
    required this.description,
  });

  @override
  List<Object?> get props => [id, title, points, description];
}

/// Rubric criterion defining scoring standards.
class AssignmentRubricItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final double maxPoints;
  final List<RubricLevel> levels;

  const AssignmentRubricItem({
    required this.id,
    required this.title,
    required this.description,
    required this.maxPoints,
    this.levels = const [],
  });

  @override
  List<Object?> get props => [id, title, description, maxPoints, levels];
}

/// Scored item for a student's submission on a specific rubric criterion.
class RubricScore extends Equatable {
  final String criterionId;
  final String criterionTitle;
  final double awardedPoints;
  final double maxPoints;
  final String? selectedLevelTitle;
  final String? comments;

  const RubricScore({
    required this.criterionId,
    required this.criterionTitle,
    required this.awardedPoints,
    required this.maxPoints,
    this.selectedLevelTitle,
    this.comments,
  });

  @override
  List<Object?> get props => [
        criterionId,
        criterionTitle,
        awardedPoints,
        maxPoints,
        selectedLevelTitle,
        comments,
      ];
}

/// Core domain entity for an assignment.
class AssignmentEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String instructorId;
  final String instructorName;
  final String title;
  final String description;
  final DateTime dueDate;
  final double totalPoints;
  final double weightPercentage;
  final SubmissionType submissionType;
  final List<String> allowedFileExtensions;
  final List<String> attachments;
  final List<AssignmentRubricItem> rubric;
  final bool isPublished;

  const AssignmentEntity({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.instructorId,
    required this.instructorName,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.totalPoints,
    this.weightPercentage = 10.0,
    this.submissionType = SubmissionType.both,
    this.allowedFileExtensions = const ['pdf', 'zip', 'dart'],
    this.attachments = const [],
    this.rubric = const [],
    this.isPublished = true,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  AssignmentStatus get status {
    if (!isPublished) return AssignmentStatus.upcoming;
    if (isOverdue) return AssignmentStatus.closed;
    return AssignmentStatus.open;
  }

  int get daysRemaining {
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  int get hoursRemaining {
    final diff = dueDate.difference(DateTime.now()).inHours;
    return diff < 0 ? 0 : diff;
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseCode,
        courseTitle,
        instructorId,
        instructorName,
        title,
        description,
        dueDate,
        totalPoints,
        weightPercentage,
        submissionType,
        allowedFileExtensions,
        attachments,
        rubric,
        isPublished,
      ];
}

/// Core domain entity for a student's submission.
class SubmissionEntity extends Equatable {
  final String id;
  final String assignmentId;
  final String assignmentTitle;
  final String courseCode;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentAvatar;
  final DateTime submittedAt;
  final String? fileName;
  final int? fileSizeBytes;
  final String? textResponse;
  final SubmissionStatus status;
  final double? score;
  final double? maxScore;
  final String? feedbackNotes;
  final DateTime? gradedAt;
  final String? gradedBy;
  final List<RubricScore> rubricScores;

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.courseCode,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatar,
    required this.submittedAt,
    this.fileName,
    this.fileSizeBytes,
    this.textResponse,
    this.status = SubmissionStatus.submitted,
    this.score,
    this.maxScore,
    this.feedbackNotes,
    this.gradedAt,
    this.gradedBy,
    this.rubricScores = const [],
  });

  bool get isGraded => status == SubmissionStatus.graded && score != null;
  bool get isLate => status == SubmissionStatus.late;

  double get scorePercentage {
    if (score == null || maxScore == null || maxScore == 0) return 0.0;
    return (score! / maxScore!) * 100.0;
  }

  String get letterGrade {
    final pct = scorePercentage;
    if (pct >= 93) return 'A';
    if (pct >= 90) return 'A-';
    if (pct >= 87) return 'B+';
    if (pct >= 83) return 'B';
    if (pct >= 80) return 'B-';
    if (pct >= 77) return 'C+';
    if (pct >= 73) return 'C';
    if (pct >= 70) return 'C-';
    if (pct >= 60) return 'D';
    return 'F';
  }

  String get formattedFileSize {
    if (fileSizeBytes == null) return '0 B';
    final bytes = fileSizeBytes!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        assignmentTitle,
        courseCode,
        studentId,
        studentName,
        studentEmail,
        studentAvatar,
        submittedAt,
        fileName,
        fileSizeBytes,
        textResponse,
        status,
        score,
        maxScore,
        feedbackNotes,
        gradedAt,
        gradedBy,
        rubricScores,
      ];
}

/// Student's summary entry in a course gradebook.
class GradebookEntry extends Equatable {
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentAvatar;
  final Map<String, double?> assignmentScores;
  final double totalPointsEarned;
  final double totalPointsPossible;
  final double percentage;
  final String letterGrade;

  const GradebookEntry({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatar,
    required this.assignmentScores,
    required this.totalPointsEarned,
    required this.totalPointsPossible,
    required this.percentage,
    required this.letterGrade,
  });

  @override
  List<Object?> get props => [
        studentId,
        studentName,
        studentEmail,
        studentAvatar,
        assignmentScores,
        totalPointsEarned,
        totalPointsPossible,
        percentage,
        letterGrade,
      ];
}

/// Course-wide gradebook entity.
class CourseGradebook extends Equatable {
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final List<AssignmentEntity> assignments;
  final List<GradebookEntry> entries;

  const CourseGradebook({
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.assignments,
    required this.entries,
  });

  double get classAveragePercentage {
    if (entries.isEmpty) return 0.0;
    final total = entries.fold<double>(0.0, (acc, e) => acc + e.percentage);
    return total / entries.length;
  }

  double get highestPercentage {
    if (entries.isEmpty) return 0.0;
    return entries.map((e) => e.percentage).reduce((a, b) => a > b ? a : b);
  }

  double get lowestPercentage {
    if (entries.isEmpty) return 0.0;
    return entries.map((e) => e.percentage).reduce((a, b) => a < b ? a : b);
  }

  @override
  List<Object?> get props => [
        courseId,
        courseCode,
        courseTitle,
        assignments,
        entries,
      ];
}
