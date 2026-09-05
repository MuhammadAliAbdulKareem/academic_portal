import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/assignment_entity.dart';

/// Data model representing a rubric level.
class RubricLevelModel {
  final String id;
  final String title;
  final double points;
  final String description;

  const RubricLevelModel({
    required this.id,
    required this.title,
    required this.points,
    required this.description,
  });

  factory RubricLevelModel.fromJson(Map<String, dynamic> json) {
    return RubricLevelModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points,
      'description': description,
    };
  }

  RubricLevel toEntity() => RubricLevel(
        id: id,
        title: title,
        points: points,
        description: description,
      );

  factory RubricLevelModel.fromEntity(RubricLevel entity) {
    return RubricLevelModel(
      id: entity.id,
      title: entity.title,
      points: entity.points,
      description: entity.description,
    );
  }
}

/// Data model representing a rubric criterion.
class AssignmentRubricItemModel {
  final String id;
  final String title;
  final String description;
  final double maxPoints;
  final List<RubricLevelModel> levels;

  const AssignmentRubricItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.maxPoints,
    this.levels = const [],
  });

  factory AssignmentRubricItemModel.fromJson(Map<String, dynamic> json) {
    return AssignmentRubricItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      maxPoints: (json['maxPoints'] as num?)?.toDouble() ?? 0.0,
      levels: (json['levels'] as List<dynamic>?)
              ?.map((e) => RubricLevelModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'maxPoints': maxPoints,
      'levels': levels.map((e) => e.toJson()).toList(),
    };
  }

  AssignmentRubricItem toEntity() => AssignmentRubricItem(
        id: id,
        title: title,
        description: description,
        maxPoints: maxPoints,
        levels: levels.map((e) => e.toEntity()).toList(),
      );

  factory AssignmentRubricItemModel.fromEntity(AssignmentRubricItem entity) {
    return AssignmentRubricItemModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      maxPoints: entity.maxPoints,
      levels: entity.levels.map((e) => RubricLevelModel.fromEntity(e)).toList(),
    );
  }
}

/// Data model representing an Assignment.
class AssignmentModel {
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
  final String submissionType;
  final List<String> allowedFileExtensions;
  final List<String> attachments;
  final List<AssignmentRubricItemModel> rubric;
  final bool isPublished;

  const AssignmentModel({
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
    this.submissionType = 'both',
    this.allowedFileExtensions = const ['pdf', 'zip', 'dart'],
    this.attachments = const [],
    this.rubric = const [],
    this.isPublished = true,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDueDate;
    if (json['dueDate'] is Timestamp) {
      parsedDueDate = (json['dueDate'] as Timestamp).toDate();
    } else if (json['dueDate'] is String) {
      parsedDueDate = DateTime.tryParse(json['dueDate'] as String) ?? DateTime.now();
    } else {
      parsedDueDate = DateTime.now();
    }

    return AssignmentModel(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      instructorId: json['instructorId'] as String? ?? '',
      instructorName: json['instructorName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: parsedDueDate,
      totalPoints: (json['totalPoints'] as num?)?.toDouble() ?? 100.0,
      weightPercentage: (json['weightPercentage'] as num?)?.toDouble() ?? 10.0,
      submissionType: json['submissionType'] as String? ?? 'both',
      allowedFileExtensions: (json['allowedFileExtensions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['pdf', 'zip', 'dart'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rubric: (json['rubric'] as List<dynamic>?)
              ?.map((e) => AssignmentRubricItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'totalPoints': totalPoints,
      'weightPercentage': weightPercentage,
      'submissionType': submissionType,
      'allowedFileExtensions': allowedFileExtensions,
      'attachments': attachments,
      'rubric': rubric.map((e) => e.toJson()).toList(),
      'isPublished': isPublished,
    };
  }

  factory AssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AssignmentModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'totalPoints': totalPoints,
      'weightPercentage': weightPercentage,
      'submissionType': submissionType,
      'allowedFileExtensions': allowedFileExtensions,
      'attachments': attachments,
      'rubric': rubric.map((e) => e.toJson()).toList(),
      'isPublished': isPublished,
    };
  }

  AssignmentEntity toEntity() {
    SubmissionType parsedType;
    switch (submissionType) {
      case 'fileUpload':
        parsedType = SubmissionType.fileUpload;
        break;
      case 'textEntry':
        parsedType = SubmissionType.textEntry;
        break;
      default:
        parsedType = SubmissionType.both;
    }

    return AssignmentEntity(
      id: id,
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      instructorId: instructorId,
      instructorName: instructorName,
      title: title,
      description: description,
      dueDate: dueDate,
      totalPoints: totalPoints,
      weightPercentage: weightPercentage,
      submissionType: parsedType,
      allowedFileExtensions: allowedFileExtensions,
      attachments: attachments,
      rubric: rubric.map((e) => e.toEntity()).toList(),
      isPublished: isPublished,
    );
  }

  factory AssignmentModel.fromEntity(AssignmentEntity entity) {
    String typeStr;
    switch (entity.submissionType) {
      case SubmissionType.fileUpload:
        typeStr = 'fileUpload';
        break;
      case SubmissionType.textEntry:
        typeStr = 'textEntry';
        break;
      case SubmissionType.both:
        typeStr = 'both';
        break;
    }

    return AssignmentModel(
      id: entity.id,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      instructorId: entity.instructorId,
      instructorName: entity.instructorName,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      totalPoints: entity.totalPoints,
      weightPercentage: entity.weightPercentage,
      submissionType: typeStr,
      allowedFileExtensions: entity.allowedFileExtensions,
      attachments: entity.attachments,
      rubric: entity.rubric.map((e) => AssignmentRubricItemModel.fromEntity(e)).toList(),
      isPublished: entity.isPublished,
    );
  }
}
