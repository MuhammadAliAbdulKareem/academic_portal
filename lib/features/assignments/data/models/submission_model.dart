import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/assignment_entity.dart';

/// Data model representing a scored rubric criterion.
class RubricScoreModel {
  final String criterionId;
  final String criterionTitle;
  final double awardedPoints;
  final double maxPoints;
  final String? selectedLevelTitle;
  final String? comments;

  const RubricScoreModel({
    required this.criterionId,
    required this.criterionTitle,
    required this.awardedPoints,
    required this.maxPoints,
    this.selectedLevelTitle,
    this.comments,
  });

  factory RubricScoreModel.fromJson(Map<String, dynamic> json) {
    return RubricScoreModel(
      criterionId: json['criterionId'] as String? ?? '',
      criterionTitle: json['criterionTitle'] as String? ?? '',
      awardedPoints: (json['awardedPoints'] as num?)?.toDouble() ?? 0.0,
      maxPoints: (json['maxPoints'] as num?)?.toDouble() ?? 0.0,
      selectedLevelTitle: json['selectedLevelTitle'] as String?,
      comments: json['comments'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criterionId': criterionId,
      'criterionTitle': criterionTitle,
      'awardedPoints': awardedPoints,
      'maxPoints': maxPoints,
      'selectedLevelTitle': selectedLevelTitle,
      'comments': comments,
    };
  }

  RubricScore toEntity() => RubricScore(
        criterionId: criterionId,
        criterionTitle: criterionTitle,
        awardedPoints: awardedPoints,
        maxPoints: maxPoints,
        selectedLevelTitle: selectedLevelTitle,
        comments: comments,
      );

  factory RubricScoreModel.fromEntity(RubricScore entity) {
    return RubricScoreModel(
      criterionId: entity.criterionId,
      criterionTitle: entity.criterionTitle,
      awardedPoints: entity.awardedPoints,
      maxPoints: entity.maxPoints,
      selectedLevelTitle: entity.selectedLevelTitle,
      comments: entity.comments,
    );
  }
}

/// Data model representing a student's submission.
class SubmissionModel {
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
  final String status;
  final double? score;
  final double? maxScore;
  final String? feedbackNotes;
  final DateTime? gradedAt;
  final String? gradedBy;
  final List<RubricScoreModel> rubricScores;

  const SubmissionModel({
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
    this.status = 'submitted',
    this.score,
    this.maxScore,
    this.feedbackNotes,
    this.gradedAt,
    this.gradedBy,
    this.rubricScores = const [],
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return SubmissionModel(
      id: json['id'] as String? ?? '',
      assignmentId: json['assignmentId'] as String? ?? '',
      assignmentTitle: json['assignmentTitle'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      studentEmail: json['studentEmail'] as String? ?? '',
      studentAvatar: json['studentAvatar'] as String?,
      submittedAt: parseDate(json['submittedAt']),
      fileName: json['fileName'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      textResponse: json['textResponse'] as String?,
      status: json['status'] as String? ?? 'submitted',
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['maxScore'] as num?)?.toDouble(),
      feedbackNotes: json['feedbackNotes'] as String?,
      gradedAt: parseNullableDate(json['gradedAt']),
      gradedBy: json['gradedBy'] as String?,
      rubricScores: (json['rubricScores'] as List<dynamic>?)
              ?.map((e) => RubricScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'assignmentTitle': assignmentTitle,
      'courseCode': courseCode,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentAvatar': studentAvatar,
      'submittedAt': submittedAt.toIso8601String(),
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'textResponse': textResponse,
      'status': status,
      'score': score,
      'maxScore': maxScore,
      'feedbackNotes': feedbackNotes,
      'gradedAt': gradedAt?.toIso8601String(),
      'gradedBy': gradedBy,
      'rubricScores': rubricScores.map((e) => e.toJson()).toList(),
    };
  }

  factory SubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SubmissionModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'assignmentTitle': assignmentTitle,
      'courseCode': courseCode,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentAvatar': studentAvatar,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'textResponse': textResponse,
      'status': status,
      'score': score,
      'maxScore': maxScore,
      'feedbackNotes': feedbackNotes,
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
      'gradedBy': gradedBy,
      'rubricScores': rubricScores.map((e) => e.toJson()).toList(),
    };
  }

  SubmissionEntity toEntity() {
    SubmissionStatus parsedStatus;
    switch (status) {
      case 'graded':
        parsedStatus = SubmissionStatus.graded;
        break;
      case 'late':
        parsedStatus = SubmissionStatus.late;
        break;
      case 'pending':
        parsedStatus = SubmissionStatus.pending;
        break;
      default:
        parsedStatus = SubmissionStatus.submitted;
    }

    return SubmissionEntity(
      id: id,
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      courseCode: courseCode,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentAvatar: studentAvatar,
      submittedAt: submittedAt,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      textResponse: textResponse,
      status: parsedStatus,
      score: score,
      maxScore: maxScore,
      feedbackNotes: feedbackNotes,
      gradedAt: gradedAt,
      gradedBy: gradedBy,
      rubricScores: rubricScores.map((e) => e.toEntity()).toList(),
    );
  }

  factory SubmissionModel.fromEntity(SubmissionEntity entity) {
    String statusStr;
    switch (entity.status) {
      case SubmissionStatus.graded:
        statusStr = 'graded';
        break;
      case SubmissionStatus.late:
        statusStr = 'late';
        break;
      case SubmissionStatus.pending:
        statusStr = 'pending';
        break;
      case SubmissionStatus.submitted:
        statusStr = 'submitted';
        break;
    }

    return SubmissionModel(
      id: entity.id,
      assignmentId: entity.assignmentId,
      assignmentTitle: entity.assignmentTitle,
      courseCode: entity.courseCode,
      studentId: entity.studentId,
      studentName: entity.studentName,
      studentEmail: entity.studentEmail,
      studentAvatar: entity.studentAvatar,
      submittedAt: entity.submittedAt,
      fileName: entity.fileName,
      fileSizeBytes: entity.fileSizeBytes,
      textResponse: entity.textResponse,
      status: statusStr,
      score: entity.score,
      maxScore: entity.maxScore,
      feedbackNotes: entity.feedbackNotes,
      gradedAt: entity.gradedAt,
      gradedBy: entity.gradedBy,
      rubricScores: entity.rubricScores.map((e) => RubricScoreModel.fromEntity(e)).toList(),
    );
  }
}
