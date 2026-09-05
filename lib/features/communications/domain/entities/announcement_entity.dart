import 'package:equatable/equatable.dart';

/// Priority tier of an announcement.
enum AnnouncementPriority {
  urgent,
  academic,
  examNotice,
  general;

  String get displayName {
    switch (this) {
      case AnnouncementPriority.urgent:
        return 'Urgent Alert';
      case AnnouncementPriority.academic:
        return 'Academic Update';
      case AnnouncementPriority.examNotice:
        return 'Exam Notice';
      case AnnouncementPriority.general:
        return 'General Info';
    }
  }

  bool get isUrgent => this == AnnouncementPriority.urgent;
}

/// Domain entity representing a broadcast course or campus announcement.
class AnnouncementEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final AnnouncementPriority priority;
  final bool isPinned;
  final DateTime publishedAt;
  final List<String> tags;
  final List<String> readByStudentIds;

  const AnnouncementEntity({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.priority,
    this.isPinned = false,
    required this.publishedAt,
    this.tags = const [],
    this.readByStudentIds = const [],
  });

  bool isReadBy(String studentId) => readByStudentIds.contains(studentId);

  bool get isCampusWide => courseId == 'all' || courseCode.toUpperCase() == 'CAMPUS';

  AnnouncementEntity copyWith({
    String? id,
    String? courseId,
    String? courseCode,
    String? courseTitle,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    AnnouncementPriority? priority,
    bool? isPinned,
    DateTime? publishedAt,
    List<String>? tags,
    List<String>? readByStudentIds,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      priority: priority ?? this.priority,
      isPinned: isPinned ?? this.isPinned,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
      readByStudentIds: readByStudentIds ?? this.readByStudentIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseCode,
        courseTitle,
        title,
        content,
        authorId,
        authorName,
        authorRole,
        authorAvatar,
        priority,
        isPinned,
        publishedAt,
        tags,
        readByStudentIds,
      ];
}
