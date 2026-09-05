import '../entities/announcement_entity.dart';
import '../entities/discussion_entity.dart';
import '../entities/notification_entity.dart';

/// Clean architecture contract defining course communications, discussions,
/// announcements, and notification operations.
abstract class CommunicationsRepository {
  /// Fetches announcements optionally filtered by course or student ID.
  Future<List<AnnouncementEntity>> getAnnouncements({
    String? courseId,
    String? studentId,
  });

  /// Creates a new broadcast announcement.
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity announcement);

  /// Marks an announcement as read/acknowledged by a student.
  Future<void> markAnnouncementAsRead({
    required String announcementId,
    required String studentId,
  });

  /// Fetches discussion threads with optional filters for course, category, and search text.
  Future<List<DiscussionThreadEntity>> getDiscussionThreads({
    String? courseId,
    DiscussionCategory? category,
    String? searchQuery,
  });

  /// Retrieves a specific discussion thread by ID including all replies.
  Future<DiscussionThreadEntity> getDiscussionThreadById(String threadId);

  /// Creates a new discussion topic / question.
  Future<DiscussionThreadEntity> createDiscussionThread(DiscussionThreadEntity thread);

  /// Appends a new reply to an existing discussion thread.
  Future<DiscussionReplyEntity> addDiscussionReply({
    required String threadId,
    required DiscussionReplyEntity reply,
  });

  /// Toggles an upvote on a reply by a specific user.
  Future<void> toggleReplyUpvote({
    required String threadId,
    required String replyId,
    required String userId,
  });

  /// Toggles the instructor endorsement on a solution.
  Future<void> toggleInstructorEndorsement({
    required String threadId,
    required String replyId,
  });

  /// Retrieves all notifications for a specific user.
  Future<List<NotificationEntity>> getNotifications(String userId);

  /// Marks a specific notification as read.
  Future<void> markNotificationAsRead(String notificationId);

  /// Marks all notifications for a user as read.
  Future<void> markAllNotificationsAsRead(String userId);
}
