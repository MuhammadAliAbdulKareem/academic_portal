import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/discussion_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/announcement_model.dart';
import '../models/discussion_model.dart';
import '../models/notification_model.dart';

abstract class CommunicationsRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements({String? courseId, String? studentId});
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement);
  Future<void> markAnnouncementAsRead({required String announcementId, required String studentId});

  Future<List<DiscussionThreadModel>> getDiscussionThreads({
    String? courseId,
    DiscussionCategory? category,
    String? searchQuery,
  });
  Future<DiscussionThreadModel> getDiscussionThreadById(String threadId);
  Future<DiscussionThreadModel> createDiscussionThread(DiscussionThreadModel thread);
  Future<DiscussionReplyModel> addDiscussionReply({required String threadId, required DiscussionReplyModel reply});
  Future<void> toggleReplyUpvote({required String threadId, required String replyId, required String userId});
  Future<void> toggleInstructorEndorsement({required String threadId, required String replyId});

  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);
}

class CommunicationsRemoteDataSourceImpl implements CommunicationsRemoteDataSource {
  final FirebaseFirestore? _firestore;
  final List<AnnouncementModel> _announcements = [];
  final List<DiscussionThreadModel> _discussions = [];
  final List<NotificationModel> _notifications = [];

  CommunicationsRemoteDataSourceImpl({FirebaseFirestore? firestore}) : _firestore = firestore {
    _seedData();
  }

  bool get _isFirebaseReady => FirebaseConfig.isInitialized && _firestore != null;

  void _seedData() {
    final now = DateTime.now();

    _announcements.addAll([
      AnnouncementModel(
        id: 'ann-1',
        courseId: 'all',
        courseCode: 'CAMPUS',
        courseTitle: 'Campus-Wide',
        title: 'Spring Midterm Examination Guidelines & Study Center Extended Hours',
        content:
            'The Academic Advisory Council has finalized the midterm timetable. The Central Library and Science Center collaborative study pods will remain open 24/7 with reserved quiet floors. Please review the updated academic honesty policy before exam week begins.',
        authorId: 'inst-01',
        authorName: 'Dr. Sarah Connor',
        authorRole: 'Academic Dean',
        authorAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
        priority: AnnouncementPriority.academic,
        isPinned: true,
        publishedAt: now.subtract(const Duration(days: 1)),
        tags: const ['Midterms', 'Campus Library', 'Guidelines'],
        readByStudentIds: const ['demo-student-01'],
      ),
      AnnouncementModel(
        id: 'ann-2',
        courseId: 'cs101',
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        title: 'URGENT: Lab 3 Due Date Extended & Lecture Room Change to Turing 204',
        content:
            'Due to scheduled server maintenance in the main server cluster, Assignment 3 (Binary Trees & Recursion) has been extended by 48 hours. Furthermore, Thursday\'s lecture will be held in Turing Hall Room 204 instead of Hall A.',
        authorId: 'inst-01',
        authorName: 'Prof. Alan Turing',
        authorRole: 'Lead Instructor',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        priority: AnnouncementPriority.urgent,
        isPinned: true,
        publishedAt: now.subtract(const Duration(hours: 3)),
        tags: ['CS101', 'Room Change', 'Extension', 'Urgent'],
        readByStudentIds: const [],
      ),
      AnnouncementModel(
        id: 'ann-3',
        courseId: 'math301',
        courseCode: 'MATH301',
        courseTitle: 'Multivariable Calculus',
        title: 'Exam 2 Formula Reference Sheet & Review Session Recording',
        content:
            'The official formula sheet permitted during Exam 2 has been posted in the course materials. The recording of Monday\'s evening review covering Green\'s Theorem and Stokes\' Theorem is now available for streaming.',
        authorId: 'inst-02',
        authorName: 'Dr. Katherine Johnson',
        authorRole: 'Professor of Mathematics',
        authorAvatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956',
        priority: AnnouncementPriority.examNotice,
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 2)),
        tags: ['MATH301', 'Formula Sheet', 'Review Session'],
        readByStudentIds: const ['demo-student-01'],
      ),
      AnnouncementModel(
        id: 'ann-4',
        courseId: 'cs201',
        courseCode: 'CS201',
        courseTitle: 'Data Structures & Algorithms',
        title: 'Distinguished Guest Speaker: High-Performance Distributed Systems at Google',
        content:
            'We are thrilled to welcome Dr. Jeff Dean for a guest presentation on large-scale distributed consensus and cache invalidation architectures next Wednesday at 4:00 PM. Attendance counts towards bonus participation credits.',
        authorId: 'inst-01',
        authorName: 'Prof. Alan Turing',
        authorRole: 'Lead Instructor',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        priority: AnnouncementPriority.general,
        isPinned: false,
        publishedAt: now.subtract(const Duration(days: 4)),
        tags: ['Guest Lecture', 'Distributed Systems', 'Industry Talk'],
        readByStudentIds: const [],
      ),
    ]);

    _discussions.addAll([
      DiscussionThreadModel(
        id: 'thread-1',
        courseId: 'cs101',
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        title: 'Recursive Fibonacci vs Memoization: Why is the call stack depth still O(N)?',
        content:
            'I understand that top-down memoization caches repeated evaluations to reduce time complexity from O(2^N) to O(N). However, when checking the auxiliary space complexity, why does it remain O(N)? Is it strictly due to the recursive call stack depth or the lookup table allocation?',
        category: DiscussionCategory.homeworkHelp,
        authorId: 'demo-student-01',
        authorName: 'Alex Mercer',
        authorRole: 'Student',
        authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        isPinned: true,
        isResolved: true,
        repliesCount: 2,
        tags: const ['Recursion', 'Time Complexity', 'Call Stack'],
        replies: [
          DiscussionReplyModel(
            id: 'reply-1',
            threadId: 'thread-1',
            authorId: 'student-02',
            authorName: 'Elena Rostova',
            authorRole: 'Student',
            authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
            content:
                'Both factors contribute! The memo table consumes O(N) memory, but even without the hash table, reaching fib(N) requires traversing a linear branch down to fib(1), leaving N activation frames on the call stack at peak depth.',
            createdAt: now.subtract(const Duration(hours: 8)),
            upvotes: 4,
            isInstructorEndorsed: false,
            upvotedByUserIds: const ['demo-student-01', 'student-03'],
          ),
          DiscussionReplyModel(
            id: 'reply-2',
            threadId: 'thread-1',
            authorId: 'inst-01',
            authorName: 'Prof. Alan Turing',
            authorRole: 'Lead Instructor',
            authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
            content:
                'Spot on, Elena! For top-down memoization, maximum stack frames = N. If you want O(1) auxiliary space, transition to bottom-up dynamic programming with two state pointers:\n\n```dart\nint fib(int n) {\n  if (n <= 1) return n;\n  int prev2 = 0, prev1 = 1;\n  for (int i = 2; i <= n; i++) {\n    int cur = prev1 + prev2;\n    prev2 = prev1;\n    prev1 = cur;\n  }\n  return prev1;\n}\n```\nThis eliminates both the recursion stack and heap array allocations.',
            createdAt: now.subtract(const Duration(hours: 2)),
            upvotes: 12,
            isInstructorEndorsed: true,
            upvotedByUserIds: const ['demo-student-01', 'student-02', 'student-04'],
          ),
        ],
      ),
      DiscussionThreadModel(
        id: 'thread-2',
        courseId: 'cs201',
        courseCode: 'CS201',
        courseTitle: 'Data Structures & Algorithms',
        title: 'B-Trees vs Red-Black Trees: In-memory performance vs block storage',
        content:
            'In which real-world application architectures would you strictly prefer a B+ Tree over an in-memory balanced BST like AVL or Red-Black, given modern CPU cache lines and NVMe throughput?',
        category: DiscussionCategory.technicalQuestions,
        authorId: 'student-03',
        authorName: 'David Kim',
        authorRole: 'Student',
        authorAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        isPinned: false,
        isResolved: true,
        repliesCount: 2,
        tags: const ['B-Trees', 'Storage', 'Databases', 'Hardware'],
        replies: [
          DiscussionReplyModel(
            id: 'reply-3',
            threadId: 'thread-2',
            authorId: 'inst-01',
            authorName: 'Prof. Alan Turing',
            authorRole: 'Lead Instructor',
            authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
            content:
                'B+ Trees excel whenever IO blocks dominate. A node holds hundreds of keys, keeping tree height under 4 even for billions of records. In relational database engines (PostgreSQL, SQLite, MySQL InnoDB), each node access corresponds to a 4KB/16KB page read.',
            createdAt: now.subtract(const Duration(hours: 14)),
            upvotes: 8,
            isInstructorEndorsed: true,
            upvotedByUserIds: const ['student-03', 'demo-student-01'],
          ),
          DiscussionReplyModel(
            id: 'reply-4',
            threadId: 'thread-2',
            authorId: 'demo-student-01',
            authorName: 'Alex Mercer',
            authorRole: 'Student',
            authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
            content:
                'Also note that in B+ Trees, all payload data pointers reside exclusively in the leaf nodes, which allows sequential linked-list range scans without tree traversals!',
            createdAt: now.subtract(const Duration(hours: 5)),
            upvotes: 5,
            isInstructorEndorsed: false,
            upvotedByUserIds: const ['student-03', 'inst-01'],
          ),
        ],
      ),
      DiscussionThreadModel(
        id: 'thread-3',
        courseId: 'math301',
        courseCode: 'MATH301',
        courseTitle: 'Multivariable Calculus',
        title: 'Virtual Study Group: Surface Integrals & Stokes Theorem Practice',
        content:
            'Anyone interested in forming a weekend problem-solving cohort before Exam 2? We can go through the past 3 semester exam papers and parameterization techniques.',
        category: DiscussionCategory.examPrep,
        authorId: 'student-02',
        authorName: 'Elena Rostova',
        authorRole: 'Student',
        authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isPinned: false,
        isResolved: false,
        repliesCount: 1,
        tags: const ['Study Group', 'Stokes Theorem', 'Exam Prep'],
        replies: [
          DiscussionReplyModel(
            id: 'reply-5',
            threadId: 'thread-3',
            authorId: 'demo-student-01',
            authorName: 'Alex Mercer',
            authorRole: 'Student',
            authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
            content: 'Count me in! Saturday afternoon at 2 PM works best for me.',
            createdAt: now.subtract(const Duration(days: 1)),
            upvotes: 2,
            isInstructorEndorsed: false,
            upvotedByUserIds: const ['student-02'],
          ),
        ],
      ),
    ]);

    _notifications.addAll([
      NotificationModel(
        id: 'notif-1',
        userId: 'demo-student-01',
        title: 'Urgent Lab 3 Notice & Room Change',
        message: 'Prof. Alan Turing posted an urgent announcement regarding CS101 lecture venue.',
        type: NotificationType.announcement,
        targetRoute: '/announcements',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-2',
        userId: 'demo-student-01',
        title: 'Upcoming Assessment: CS101 Midterm Quiz',
        message: 'Interactive Quiz on Recursion & Memory Models is scheduled for this week.',
        type: NotificationType.quizDue,
        targetRoute: '/quizzes',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-3',
        userId: 'demo-student-01',
        title: 'Discussion Endorsed by Instructor',
        message: 'Prof. Alan Turing verified a solution in thread "Recursive Fibonacci vs Memoization".',
        type: NotificationType.discussionReply,
        targetRoute: '/discussions/thread-1',
        createdAt: now.subtract(const Duration(hours: 8)),
        isRead: false,
      ),
      NotificationModel(
        id: 'notif-4',
        userId: 'demo-student-01',
        title: 'Grade Posted: CS201 Assignment 1',
        message: 'Your rubric evaluation has been published with 95/100 points (Grade: A).',
        type: NotificationType.gradePublished,
        targetRoute: '/assignments',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 'notif-5',
        userId: 'demo-student-01',
        title: 'Attendance Confirmed: Lecture 14',
        message: 'Your QR check-in was successfully recorded at 09:02 AM.',
        type: NotificationType.attendanceAlert,
        targetRoute: '/attendance',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ]);
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements({String? courseId, String? studentId}) async {
    if (_isFirebaseReady) {
      try {
        Query<Map<String, dynamic>> query = _firestore!.collection('announcements');
        if (courseId != null && courseId.isNotEmpty && courseId.toLowerCase() != 'all') {
          query = query.where('courseId', isEqualTo: courseId);
        }
        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs
              .map((d) => AnnouncementModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
          list.sort((a, b) {
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            return b.publishedAt.compareTo(a.publishedAt);
          });
          return list;
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<AnnouncementModel>.from(_announcements);

    if (courseId != null && courseId.isNotEmpty && courseId.toLowerCase() != 'all') {
      results = results
          .where((a) => a.courseId == 'all' || a.courseId.toLowerCase() == courseId.toLowerCase())
          .toList();
    }

    results.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });

    return results;
  }

  @override
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement) async {
    final id = announcement.id.isNotEmpty
        ? announcement.id
        : 'ann-${DateTime.now().millisecondsSinceEpoch}';
    final toSave = AnnouncementModel.fromEntity(announcement.copyWith(id: id));

    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('announcements').doc(id).set(toSave.toJson());
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _announcements.insert(0, toSave);

    // Also dispatch a notification to demo student
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo-student-01',
        title: 'New Announcement: ${announcement.title}',
        message: '${announcement.authorName} posted in ${announcement.courseCode}.',
        type: NotificationType.announcement,
        targetRoute: '/announcements',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );

    return toSave;
  }

  @override
  Future<void> markAnnouncementAsRead({required String announcementId, required String studentId}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _announcements.indexWhere((a) => a.id == announcementId);
    if (index != -1) {
      final current = _announcements[index];
      if (!current.readByStudentIds.contains(studentId)) {
        final updatedIds = List<String>.from(current.readByStudentIds)..add(studentId);
        _announcements[index] = AnnouncementModel.fromEntity(current.copyWith(readByStudentIds: updatedIds));
      }
    }
  }

  @override
  Future<List<DiscussionThreadModel>> getDiscussionThreads({
    String? courseId,
    DiscussionCategory? category,
    String? searchQuery,
  }) async {
    if (_isFirebaseReady) {
      try {
        Query<Map<String, dynamic>> query = _firestore!.collection('discussions');
        if (courseId != null && courseId.isNotEmpty && courseId.toLowerCase() != 'all') {
          query = query.where('courseId', isEqualTo: courseId);
        }
        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          var list = snap.docs
              .map((d) => DiscussionThreadModel.fromJson({...d.data(), 'id': d.id}))
              .toList();

          if (category != null) {
            list = list.where((t) => t.category == category).toList();
          }

          if (searchQuery != null && searchQuery.trim().isNotEmpty) {
            final q = searchQuery.toLowerCase().trim();
            list = list.where((t) {
              return t.title.toLowerCase().contains(q) ||
                  t.content.toLowerCase().contains(q) ||
                  t.courseCode.toLowerCase().contains(q) ||
                  t.tags.any((tag) => tag.toLowerCase().contains(q));
            }).toList();
          }

          list.sort((a, b) {
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });

          return list;
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<DiscussionThreadModel>.from(_discussions);

    if (courseId != null && courseId.isNotEmpty && courseId.toLowerCase() != 'all') {
      results = results
          .where((t) => t.courseId.toLowerCase() == courseId.toLowerCase())
          .toList();
    }

    if (category != null) {
      results = results.where((t) => t.category == category).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      results = results.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.content.toLowerCase().contains(q) ||
            t.courseCode.toLowerCase().contains(q) ||
            t.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    results.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return results;
  }

  @override
  Future<DiscussionThreadModel> getDiscussionThreadById(String threadId) async {
    if (_isFirebaseReady) {
      try {
        final doc = await _firestore!.collection('discussions').doc(threadId).get();
        if (doc.exists && doc.data() != null) {
          final repliesSnap = await _firestore
              .collection('discussions')
              .doc(threadId)
              .collection('replies')
              .get();
          final replies = repliesSnap.docs
              .map((r) => DiscussionReplyModel.fromJson({...r.data(), 'id': r.id}))
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          final base = DiscussionThreadModel.fromJson({...doc.data()!, 'id': doc.id});
          return DiscussionThreadModel.fromEntity(base.copyWith(
            replies: replies.isNotEmpty ? replies : base.replies,
            repliesCount: replies.isNotEmpty ? replies.length : base.repliesCount,
          ));
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final thread = _discussions.firstWhere(
      (t) => t.id == threadId,
      orElse: () => throw Exception('Discussion thread with ID $threadId not found.'),
    );
    return thread;
  }

  @override
  Future<DiscussionThreadModel> createDiscussionThread(DiscussionThreadModel thread) async {
    final id = thread.id.isNotEmpty
        ? thread.id
        : 'thread-${DateTime.now().millisecondsSinceEpoch}';
    final toSave = DiscussionThreadModel.fromEntity(thread.copyWith(id: id));

    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('discussions').doc(id).set(toSave.toJson());
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _discussions.insert(0, toSave);
    return toSave;
  }

  @override
  Future<DiscussionReplyModel> addDiscussionReply({
    required String threadId,
    required DiscussionReplyModel reply,
  }) async {
    final rId = reply.id.isNotEmpty
        ? reply.id
        : 'reply-${DateTime.now().millisecondsSinceEpoch}';
    final toSave = DiscussionReplyModel.fromEntity(reply.copyWith(id: rId));

    if (_isFirebaseReady) {
      try {
        await _firestore!
            .collection('discussions')
            .doc(threadId)
            .collection('replies')
            .doc(rId)
            .set(toSave.toJson());

        await _firestore.collection('discussions').doc(threadId).update({
          'repliesCount': FieldValue.increment(1),
          'lastActivityAt': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    final index = _discussions.indexWhere((t) => t.id == threadId);
    if (index != -1) {
      final thread = _discussions[index];
      final updatedReplies = List<DiscussionReplyEntity>.from(thread.replies)..add(toSave);
      _discussions[index] = DiscussionThreadModel.fromEntity(thread.copyWith(
        replies: updatedReplies,
        repliesCount: updatedReplies.length,
        updatedAt: DateTime.now(),
      ));
    }

    return toSave;
  }

  @override
  Future<void> toggleReplyUpvote({
    required String threadId,
    required String replyId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final threadIndex = _discussions.indexWhere((t) => t.id == threadId);
    if (threadIndex == -1) return;

    final thread = _discussions[threadIndex];
    final replyIndex = thread.replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final reply = thread.replies[replyIndex];
    final upvoters = List<String>.from(reply.upvotedByUserIds);

    final bool alreadyUpvoted = upvoters.contains(userId);
    if (alreadyUpvoted) {
      upvoters.remove(userId);
    } else {
      upvoters.add(userId);
    }

    final updatedReply = reply.copyWith(
      upvotedByUserIds: upvoters,
      upvotes: alreadyUpvoted ? (reply.upvotes > 0 ? reply.upvotes - 1 : 0) : reply.upvotes + 1,
    );

    final updatedReplies = List<DiscussionReplyEntity>.from(thread.replies);
    updatedReplies[replyIndex] = updatedReply;

    _discussions[threadIndex] = DiscussionThreadModel.fromEntity(thread.copyWith(
      replies: updatedReplies,
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<void> toggleInstructorEndorsement({
    required String threadId,
    required String replyId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final threadIndex = _discussions.indexWhere((t) => t.id == threadId);
    if (threadIndex == -1) return;

    final thread = _discussions[threadIndex];
    final replyIndex = thread.replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final reply = thread.replies[replyIndex];
    final bool newEndorsement = !reply.isInstructorEndorsed;

    final updatedReply = reply.copyWith(isInstructorEndorsed: newEndorsement);
    final updatedReplies = List<DiscussionReplyEntity>.from(thread.replies);
    updatedReplies[replyIndex] = updatedReply;

    _discussions[threadIndex] = DiscussionThreadModel.fromEntity(thread.copyWith(
      replies: updatedReplies,
      isResolved: newEndorsement || updatedReplies.any((r) => r.isInstructorEndorsed),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final results = _notifications
        .where((n) => n.userId == userId || n.userId == 'all')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel.fromEntity(_notifications[index].copyWith(isRead: true));
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId || _notifications[i].userId == 'all') {
        _notifications[i] = NotificationModel.fromEntity(_notifications[i].copyWith(isRead: true));
      }
    }
  }
}
