import '../../domain/entities/notification_entity.dart';

/// Data model for user notifications with JSON serialization.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.targetRoute,
    required super.createdAt,
    super.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseNotificationType(json['type'] as String?),
      targetRoute: json['targetRoute'] as String? ?? '/',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as DateTime? ?? DateTime.now()),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      targetRoute: entity.targetRoute,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'targetRoute': targetRoute,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  static NotificationType _parseNotificationType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'assignmentdue':
      case 'assignment_due':
        return NotificationType.assignmentDue;
      case 'quizdue':
      case 'quiz_due':
        return NotificationType.quizDue;
      case 'gradepublished':
      case 'grade_published':
        return NotificationType.gradePublished;
      case 'attendancealert':
      case 'attendance_alert':
        return NotificationType.attendanceAlert;
      case 'discussionreply':
      case 'discussion_reply':
        return NotificationType.discussionReply;
      default:
        return NotificationType.announcement;
    }
  }
}
