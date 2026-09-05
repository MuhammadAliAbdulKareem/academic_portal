import 'package:equatable/equatable.dart';

/// Semantic classification of user notifications.
enum NotificationType {
  announcement,
  assignmentDue,
  quizDue,
  gradePublished,
  attendanceAlert,
  discussionReply;

  String get displayName {
    switch (this) {
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.assignmentDue:
        return 'Assignment Deadline';
      case NotificationType.quizDue:
        return 'Quiz Reminder';
      case NotificationType.gradePublished:
        return 'Grade Posted';
      case NotificationType.attendanceAlert:
        return 'Attendance Notice';
      case NotificationType.discussionReply:
        return 'Discussion Reply';
    }
  }
}

/// Domain entity representing a real-time actionable user notification.
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String targetRoute;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.targetRoute,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? targetRoute,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetRoute: targetRoute ?? this.targetRoute,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        targetRoute,
        createdAt,
        isRead,
      ];
}
