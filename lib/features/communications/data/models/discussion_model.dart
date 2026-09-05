import '../../domain/entities/discussion_entity.dart';

/// Data model for discussion replies with JSON serialization.
class DiscussionReplyModel extends DiscussionReplyEntity {
  const DiscussionReplyModel({
    required super.id,
    required super.threadId,
    required super.authorId,
    required super.authorName,
    required super.authorRole,
    super.authorAvatar,
    required super.content,
    required super.createdAt,
    super.upvotes = 0,
    super.isInstructorEndorsed = false,
    super.upvotedByUserIds = const [],
  });

  factory DiscussionReplyModel.fromJson(Map<String, dynamic> json) {
    return DiscussionReplyModel(
      id: json['id'] as String,
      threadId: json['threadId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String? ?? 'Student',
      authorAvatar: json['authorAvatar'] as String?,
      content: json['content'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as DateTime? ?? DateTime.now()),
      upvotes: json['upvotes'] as int? ?? 0,
      isInstructorEndorsed: json['isInstructorEndorsed'] as bool? ?? false,
      upvotedByUserIds: (json['upvotedByUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory DiscussionReplyModel.fromEntity(DiscussionReplyEntity entity) {
    return DiscussionReplyModel(
      id: entity.id,
      threadId: entity.threadId,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorRole: entity.authorRole,
      authorAvatar: entity.authorAvatar,
      content: entity.content,
      createdAt: entity.createdAt,
      upvotes: entity.upvotes,
      isInstructorEndorsed: entity.isInstructorEndorsed,
      upvotedByUserIds: entity.upvotedByUserIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'upvotes': upvotes,
      'isInstructorEndorsed': isInstructorEndorsed,
      'upvotedByUserIds': upvotedByUserIds,
    };
  }
}

/// Data model for discussion threads with JSON serialization.
class DiscussionThreadModel extends DiscussionThreadEntity {
  const DiscussionThreadModel({
    required super.id,
    required super.courseId,
    required super.courseCode,
    required super.courseTitle,
    required super.title,
    required super.content,
    required super.category,
    required super.authorId,
    required super.authorName,
    required super.authorRole,
    super.authorAvatar,
    required super.createdAt,
    required super.updatedAt,
    super.isPinned = false,
    super.isResolved = false,
    super.repliesCount = 0,
    super.replies = const [],
    super.tags = const [],
  });

  factory DiscussionThreadModel.fromJson(Map<String, dynamic> json) {
    final repliesJson = json['replies'] as List<dynamic>?;
    final repliesList = repliesJson != null
        ? repliesJson
            .map((r) => DiscussionReplyModel.fromJson(r as Map<String, dynamic>))
            .toList()
        : <DiscussionReplyModel>[];

    return DiscussionThreadModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      courseCode: json['courseCode'] as String,
      courseTitle: json['courseTitle'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: _parseCategory(json['category'] as String?),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String? ?? 'Student',
      authorAvatar: json['authorAvatar'] as String?,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as DateTime? ?? DateTime.now()),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updatedAt'] as DateTime? ?? DateTime.now()),
      isPinned: json['isPinned'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
      repliesCount: json['repliesCount'] as int? ?? repliesList.length,
      replies: repliesList,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory DiscussionThreadModel.fromEntity(DiscussionThreadEntity entity) {
    return DiscussionThreadModel(
      id: entity.id,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      title: entity.title,
      content: entity.content,
      category: entity.category,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorRole: entity.authorRole,
      authorAvatar: entity.authorAvatar,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isPinned: entity.isPinned,
      isResolved: entity.isResolved,
      repliesCount: entity.repliesCount,
      replies: entity.replies,
      tags: entity.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'title': title,
      'content': content,
      'category': category.name,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'isResolved': isResolved,
      'repliesCount': repliesCount,
      'replies': replies.map((r) {
        if (r is DiscussionReplyModel) return r.toJson();
        return DiscussionReplyModel.fromEntity(r).toJson();
      }).toList(),
      'tags': tags,
    };
  }

  static DiscussionCategory _parseCategory(String? categoryStr) {
    switch (categoryStr?.toLowerCase()) {
      case 'homeworkhelp':
      case 'homework_help':
        return DiscussionCategory.homeworkHelp;
      case 'examprep':
      case 'exam_prep':
        return DiscussionCategory.examPrep;
      case 'projectcollab':
      case 'project_collab':
        return DiscussionCategory.projectCollab;
      case 'technicalquestions':
      case 'technical_questions':
        return DiscussionCategory.technicalQuestions;
      default:
        return DiscussionCategory.general;
    }
  }
}
