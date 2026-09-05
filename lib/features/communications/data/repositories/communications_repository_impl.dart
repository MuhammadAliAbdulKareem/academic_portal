import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/discussion_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/communications_repository.dart';
import '../datasources/communications_remote_data_source.dart';
import '../models/announcement_model.dart';
import '../models/discussion_model.dart';

class CommunicationsRepositoryImpl implements CommunicationsRepository {
  final CommunicationsRemoteDataSource remoteDataSource;

  const CommunicationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AnnouncementEntity>> getAnnouncements({String? courseId, String? studentId}) async {
    try {
      return await remoteDataSource.getAnnouncements(courseId: courseId, studentId: studentId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve announcements: $e');
    }
  }

  @override
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity announcement) async {
    try {
      final model = AnnouncementModel.fromEntity(announcement);
      return await remoteDataSource.createAnnouncement(model);
    } catch (e) {
      throw ServerException(message: 'Failed to create announcement: $e');
    }
  }

  @override
  Future<void> markAnnouncementAsRead({required String announcementId, required String studentId}) async {
    try {
      await remoteDataSource.markAnnouncementAsRead(
        announcementId: announcementId,
        studentId: studentId,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to mark announcement as read: $e');
    }
  }

  @override
  Future<List<DiscussionThreadEntity>> getDiscussionThreads({
    String? courseId,
    DiscussionCategory? category,
    String? searchQuery,
  }) async {
    try {
      return await remoteDataSource.getDiscussionThreads(
        courseId: courseId,
        category: category,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve discussion threads: $e');
    }
  }

  @override
  Future<DiscussionThreadEntity> getDiscussionThreadById(String threadId) async {
    try {
      return await remoteDataSource.getDiscussionThreadById(threadId);
    } catch (e) {
      throw ServerException(message: 'Failed to load discussion thread: $e');
    }
  }

  @override
  Future<DiscussionThreadEntity> createDiscussionThread(DiscussionThreadEntity thread) async {
    try {
      final model = DiscussionThreadModel.fromEntity(thread);
      return await remoteDataSource.createDiscussionThread(model);
    } catch (e) {
      throw ServerException(message: 'Failed to create discussion thread: $e');
    }
  }

  @override
  Future<DiscussionReplyEntity> addDiscussionReply({
    required String threadId,
    required DiscussionReplyEntity reply,
  }) async {
    try {
      final model = DiscussionReplyModel.fromEntity(reply);
      return await remoteDataSource.addDiscussionReply(threadId: threadId, reply: model);
    } catch (e) {
      throw ServerException(message: 'Failed to post reply: $e');
    }
  }

  @override
  Future<void> toggleReplyUpvote({
    required String threadId,
    required String replyId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.toggleReplyUpvote(
        threadId: threadId,
        replyId: replyId,
        userId: userId,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to toggle upvote: $e');
    }
  }

  @override
  Future<void> toggleInstructorEndorsement({
    required String threadId,
    required String replyId,
  }) async {
    try {
      await remoteDataSource.toggleInstructorEndorsement(
        threadId: threadId,
        replyId: replyId,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to toggle instructor endorsement: $e');
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    try {
      return await remoteDataSource.getNotifications(userId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve notifications: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await remoteDataSource.markNotificationAsRead(notificationId);
    } catch (e) {
      throw ServerException(message: 'Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await remoteDataSource.markAllNotificationsAsRead(userId);
    } catch (e) {
      throw ServerException(message: 'Failed to mark all notifications as read: $e');
    }
  }
}
