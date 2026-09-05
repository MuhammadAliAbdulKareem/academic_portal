import 'package:equatable/equatable.dart';

/// Categories for academic discussion topics.
enum DiscussionCategory {
  general,
  homeworkHelp,
  examPrep,
  projectCollab,
  technicalQuestions;

  String get displayName {
    switch (this) {
      case DiscussionCategory.general:
        return 'General Discussion';
      case DiscussionCategory.homeworkHelp:
        return 'Homework Help';
      case DiscussionCategory.examPrep:
        return 'Exam Prep';
      case DiscussionCategory.projectCollab:
        return 'Project Collaboration';
      case DiscussionCategory.technicalQuestions:
        return 'Technical Q&A';
    }
  }
}

/// Reply to an academic discussion thread.
class DiscussionReplyEntity extends Equatable {
  final String id;
  final String threadId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final int upvotes;
  final bool isInstructorEndorsed;
  final List<String> upvotedByUserIds;

  const DiscussionReplyEntity({
    required this.id,
    required this.threadId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.upvotes = 0,
    this.isInstructorEndorsed = false,
    this.upvotedByUserIds = const [],
  });

  bool hasUpvoted(String userId) => upvotedByUserIds.contains(userId);

  DiscussionReplyEntity copyWith({
    String? id,
    String? threadId,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    String? content,
    DateTime? createdAt,
    int? upvotes,
    bool? isInstructorEndorsed,
    List<String>? upvotedByUserIds,
  }) {
    return DiscussionReplyEntity(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      upvotes: upvotes ?? this.upvotes,
      isInstructorEndorsed: isInstructorEndorsed ?? this.isInstructorEndorsed,
      upvotedByUserIds: upvotedByUserIds ?? this.upvotedByUserIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        threadId,
        authorId,
        authorName,
        authorRole,
        authorAvatar,
        content,
        createdAt,
        upvotes,
        isInstructorEndorsed,
        upvotedByUserIds,
      ];
}

/// Domain entity representing a threaded discussion topic or Q&A question.
class DiscussionThreadEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String content;
  final DiscussionCategory category;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isResolved;
  final int repliesCount;
  final List<DiscussionReplyEntity> replies;
  final List<String> tags;

  const DiscussionThreadEntity({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isResolved = false,
    this.repliesCount = 0,
    this.replies = const [],
    this.tags = const [],
  });

  bool get hasInstructorEndorsement =>
      replies.any((reply) => reply.isInstructorEndorsed);

  DiscussionThreadEntity copyWith({
    String? id,
    String? courseId,
    String? courseCode,
    String? courseTitle,
    String? title,
    String? content,
    DiscussionCategory? category,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isResolved,
    int? repliesCount,
    List<DiscussionReplyEntity>? replies,
    List<String>? tags,
  }) {
    return DiscussionThreadEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isResolved: isResolved ?? this.isResolved,
      repliesCount: repliesCount ?? this.repliesCount,
      replies: replies ?? this.replies,
      tags: tags ?? this.tags,
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
        category,
        authorId,
        authorName,
        authorRole,
        authorAvatar,
        createdAt,
        updatedAt,
        isPinned,
        isResolved,
        repliesCount,
        replies,
        tags,
      ];
}
