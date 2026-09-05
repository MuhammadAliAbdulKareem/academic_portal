import '../../domain/entities/announcement_entity.dart';

/// Data model representing an announcement with JSON and Firestore serialization.
class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.courseId,
    required super.courseCode,
    required super.courseTitle,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.authorRole,
    super.authorAvatar,
    required super.priority,
    super.isPinned = false,
    required super.publishedAt,
    super.tags = const [],
    super.readByStudentIds = const [],
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String? ?? 'all',
      courseCode: json['courseCode'] as String? ?? 'CAMPUS',
      courseTitle: json['courseTitle'] as String? ?? 'Campus-Wide',
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String? ?? 'Faculty',
      authorAvatar: json['authorAvatar'] as String?,
      priority: _parsePriority(json['priority'] as String?),
      isPinned: json['isPinned'] as bool? ?? false,
      publishedAt: json['publishedAt'] is String
          ? DateTime.parse(json['publishedAt'] as String)
          : (json['publishedAt'] as DateTime? ?? DateTime.now()),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      readByStudentIds: (json['readByStudentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory AnnouncementModel.fromEntity(AnnouncementEntity entity) {
    return AnnouncementModel(
      id: entity.id,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      title: entity.title,
      content: entity.content,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorRole: entity.authorRole,
      authorAvatar: entity.authorAvatar,
      priority: entity.priority,
      isPinned: entity.isPinned,
      publishedAt: entity.publishedAt,
      tags: entity.tags,
      readByStudentIds: entity.readByStudentIds,
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
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatar': authorAvatar,
      'priority': priority.name,
      'isPinned': isPinned,
      'publishedAt': publishedAt.toIso8601String(),
      'tags': tags,
      'readByStudentIds': readByStudentIds,
    };
  }

  static AnnouncementPriority _parsePriority(String? priorityStr) {
    switch (priorityStr?.toLowerCase()) {
      case 'urgent':
        return AnnouncementPriority.urgent;
      case 'academic':
        return AnnouncementPriority.academic;
      case 'examnotice':
      case 'exam_notice':
        return AnnouncementPriority.examNotice;
      default:
        return AnnouncementPriority.general;
    }
  }
}
