import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:academic_portal/features/communications/domain/entities/announcement_entity.dart';
import 'package:academic_portal/features/communications/domain/entities/discussion_entity.dart';
import 'package:academic_portal/features/communications/domain/entities/notification_entity.dart';
import 'package:academic_portal/features/communications/data/datasources/communications_remote_data_source.dart';
import 'package:academic_portal/features/communications/data/repositories/communications_repository_impl.dart';
import 'package:academic_portal/features/communications/presentation/cubit/announcements_cubit.dart';
import 'package:academic_portal/features/communications/presentation/cubit/announcements_state.dart';
import 'package:academic_portal/features/communications/presentation/cubit/discussions_cubit.dart';
import 'package:academic_portal/features/communications/presentation/cubit/discussions_state.dart';
import 'package:academic_portal/features/communications/presentation/cubit/discussion_detail_cubit.dart';
import 'package:academic_portal/features/communications/presentation/cubit/discussion_detail_state.dart';
import 'package:academic_portal/features/communications/presentation/cubit/notifications_cubit.dart';
import 'package:academic_portal/features/communications/presentation/cubit/notifications_state.dart';
import 'package:academic_portal/features/communications/presentation/widgets/announcement_card.dart';
import 'package:academic_portal/features/communications/presentation/widgets/discussion_thread_card.dart';
import 'package:academic_portal/features/communications/presentation/widgets/discussion_reply_card.dart';
import 'package:academic_portal/features/communications/presentation/widgets/notification_badge_button.dart';

void main() {
  group('Communications Remote Data Source & Repository Tests', () {
    late CommunicationsRemoteDataSource dataSource;
    late CommunicationsRepositoryImpl repository;

    setUp(() {
      dataSource = CommunicationsRemoteDataSourceImpl();
      repository = CommunicationsRepositoryImpl(remoteDataSource: dataSource);
    });

    test('getAnnouncements returns seeded announcements and filters by course', () async {
      final all = await repository.getAnnouncements();
      expect(all.length, greaterThanOrEqualTo(3));

      final cs101 = await repository.getAnnouncements(courseId: 'cs101');
      expect(cs101.any((a) => a.courseId == 'cs101'), isTrue);
      // Campus-wide announcements also show in course views
      expect(cs101.any((a) => a.courseId == 'all'), isTrue);
    });

    test('createAnnouncement adds announcement and dispatches notification', () async {
      final newAnn = AnnouncementEntity(
        id: 'ann-test-99',
        courseId: 'cs101',
        courseCode: 'CS101',
        courseTitle: 'Intro to Computer Science',
        title: 'Midterm Review Session',
        content: 'Review session will be held on Zoom.',
        authorId: 'inst-01',
        authorName: 'Prof. Alan Turing',
        authorRole: 'Instructor',
        priority: AnnouncementPriority.academic,
        isPinned: false,
        publishedAt: DateTime.now(),
        tags: const ['Review', 'Midterm'],
        readByStudentIds: const [],
      );

      final created = await repository.createAnnouncement(newAnn);
      expect(created.id, 'ann-test-99');

      final list = await repository.getAnnouncements(courseId: 'cs101');
      expect(list.any((a) => a.id == 'ann-test-99'), isTrue);

      final notifs = await repository.getNotifications('demo-student-01');
      expect(notifs.any((n) => n.title.contains('Midterm Review Session')), isTrue);
    });

    test('markAnnouncementAsRead records student read receipt', () async {
      final listBefore = await repository.getAnnouncements();
      final target = listBefore.firstWhere((a) => !a.isReadBy('demo-student-01'));

      await repository.markAnnouncementAsRead(
        announcementId: target.id,
        studentId: 'demo-student-01',
      );

      final listAfter = await repository.getAnnouncements();
      final updated = listAfter.firstWhere((a) => a.id == target.id);
      expect(updated.isReadBy('demo-student-01'), isTrue);
    });

    test('getDiscussionThreads filters by category and search text', () async {
      final all = await repository.getDiscussionThreads();
      expect(all.isNotEmpty, isTrue);

      final homework = await repository.getDiscussionThreads(category: DiscussionCategory.homeworkHelp);
      for (final t in homework) {
        expect(t.category, DiscussionCategory.homeworkHelp);
      }

      final search = await repository.getDiscussionThreads(searchQuery: 'Fibonacci');
      expect(search.isNotEmpty, isTrue);
      expect(search.first.title.contains('Fibonacci'), isTrue);
    });

    test('addDiscussionReply appends reply and updates repliesCount', () async {
      final thread = (await repository.getDiscussionThreads()).first;
      final initialCount = thread.repliesCount;

      final newReply = DiscussionReplyEntity(
        id: 'reply-test-100',
        threadId: thread.id,
        authorId: 'student-99',
        authorName: 'Test Student',
        authorRole: 'Student',
        content: 'This is a test reply solving the problem.',
        createdAt: DateTime.now(),
        upvotes: 0,
        isInstructorEndorsed: false,
        upvotedByUserIds: const [],
      );

      await repository.addDiscussionReply(threadId: thread.id, reply: newReply);

      final updatedThread = await repository.getDiscussionThreadById(thread.id);
      expect(updatedThread.repliesCount, initialCount + 1);
      expect(updatedThread.replies.any((r) => r.id == 'reply-test-100'), isTrue);
    });

    test('toggleReplyUpvote increments and decrements upvotes', () async {
      final thread = (await repository.getDiscussionThreads()).first;
      final reply = thread.replies.first;
      final initialUpvotes = reply.upvotes;

      // Upvote
      await repository.toggleReplyUpvote(
        threadId: thread.id,
        replyId: reply.id,
        userId: 'unique-voter-01',
      );

      var updatedThread = await repository.getDiscussionThreadById(thread.id);
      var updatedReply = updatedThread.replies.firstWhere((r) => r.id == reply.id);
      expect(updatedReply.upvotes, initialUpvotes + 1);
      expect(updatedReply.hasUpvoted('unique-voter-01'), isTrue);

      // Remove upvote
      await repository.toggleReplyUpvote(
        threadId: thread.id,
        replyId: reply.id,
        userId: 'unique-voter-01',
      );

      updatedThread = await repository.getDiscussionThreadById(thread.id);
      updatedReply = updatedThread.replies.firstWhere((r) => r.id == reply.id);
      expect(updatedReply.upvotes, initialUpvotes);
      expect(updatedReply.hasUpvoted('unique-voter-01'), isFalse);
    });

    test('toggleInstructorEndorsement toggles verified flag', () async {
      final thread = (await repository.getDiscussionThreads()).first;
      final reply = thread.replies.first;
      final initialEndorsed = reply.isInstructorEndorsed;

      await repository.toggleInstructorEndorsement(
        threadId: thread.id,
        replyId: reply.id,
      );

      final updatedThread = await repository.getDiscussionThreadById(thread.id);
      final updatedReply = updatedThread.replies.firstWhere((r) => r.id == reply.id);
      expect(updatedReply.isInstructorEndorsed, !initialEndorsed);
    });

    test('notifications markAsRead and markAllAsRead', () async {
      final notifs = await repository.getNotifications('demo-student-01');
      expect(notifs.isNotEmpty, isTrue);

      final unread = notifs.where((n) => !n.isRead).toList();
      if (unread.isNotEmpty) {
        await repository.markNotificationAsRead(unread.first.id);
        final afterOne = await repository.getNotifications('demo-student-01');
        final target = afterOne.firstWhere((n) => n.id == unread.first.id);
        expect(target.isRead, isTrue);
      }

      await repository.markAllNotificationsAsRead('demo-student-01');
      final afterAll = await repository.getNotifications('demo-student-01');
      expect(afterAll.every((n) => n.isRead), isTrue);
    });
  });

  group('Communications Cubit State Tests', () {
    late CommunicationsRemoteDataSource dataSource;
    late CommunicationsRepositoryImpl repository;

    setUp(() {
      dataSource = CommunicationsRemoteDataSourceImpl();
      repository = CommunicationsRepositoryImpl(remoteDataSource: dataSource);
    });

    test('AnnouncementsCubit emits loaded and filters announcements', () async {
      final cubit = AnnouncementsCubit(repository: repository);
      expect(cubit.state, isA<AnnouncementsInitial>());

      await cubit.loadAnnouncements();
      expect(cubit.state, isA<AnnouncementsLoaded>());

      cubit.filterByPriority(AnnouncementPriority.urgent);
      var loaded = cubit.state as AnnouncementsLoaded;
      expect(loaded.selectedPriority, AnnouncementPriority.urgent);
      expect(loaded.filteredAnnouncements.every((a) => a.priority == AnnouncementPriority.urgent), isTrue);

      cubit.setSearchQuery('Turing');
      loaded = cubit.state as AnnouncementsLoaded;
      expect(loaded.filteredAnnouncements.isNotEmpty, isTrue);

      await cubit.close();
    });

    test('DiscussionsCubit emits loaded and toggles unresolved', () async {
      final cubit = DiscussionsCubit(repository: repository);
      expect(cubit.state, isA<DiscussionsInitial>());

      await cubit.loadDiscussions();
      expect(cubit.state, isA<DiscussionsLoaded>());

      cubit.toggleUnresolvedOnly();
      final loaded = cubit.state as DiscussionsLoaded;
      expect(loaded.onlyUnresolved, isTrue);
      expect(loaded.filteredThreads.every((t) => !t.isResolved), isTrue);

      await cubit.close();
    });

    test('DiscussionDetailCubit loads thread and handles replies', () async {
      final cubit = DiscussionDetailCubit(repository: repository);
      expect(cubit.state, isA<DiscussionDetailInitial>());

      await cubit.loadThread('thread-1');
      expect(cubit.state, isA<DiscussionDetailLoaded>());
      final loaded = cubit.state as DiscussionDetailLoaded;
      expect(loaded.thread.id, 'thread-1');

      await cubit.close();
    });

    test('NotificationsCubit loads notifications and calculates unreadCount', () async {
      final cubit = NotificationsCubit(repository: repository);
      expect(cubit.state, isA<NotificationsInitial>());

      await cubit.loadNotifications('demo-student-01');
      expect(cubit.state, isA<NotificationsLoaded>());
      final loaded = cubit.state as NotificationsLoaded;
      expect(loaded.unreadCount, greaterThan(0));
      expect(loaded.hasUnread, isTrue);

      await cubit.close();
    });
  });

  group('Communications Presentation Widgets Tests', () {
    testWidgets('AnnouncementCard renders title, priority badge, and handles mark as read', (tester) async {
      bool acknowledged = false;

      final announcement = AnnouncementEntity(
        id: 'ann-w-1',
        courseId: 'cs101',
        courseCode: 'CS101',
        courseTitle: 'Intro to Computer Science',
        title: 'Exam Hall Assignment Announced',
        content: 'Final exam will be split between Halls A and B.',
        authorId: 'inst-01',
        authorName: 'Prof. Alan Turing',
        authorRole: 'Instructor',
        priority: AnnouncementPriority.urgent,
        isPinned: true,
        publishedAt: DateTime.now(),
        tags: const ['Exams', 'Venues'],
        readByStudentIds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnnouncementCard(
              announcement: announcement,
              currentUserId: 'student-01',
              onAcknowledge: () {
                acknowledged = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Exam Hall Assignment Announced'), findsOneWidget);
      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('PINNED'), findsOneWidget);
      expect(find.text('CS101'), findsOneWidget);
      expect(find.text('Mark as Read'), findsOneWidget);

      await tester.tap(find.text('Mark as Read'));
      await tester.pump();
      expect(acknowledged, isTrue);
    });

    testWidgets('DiscussionThreadCard displays title and replies counter', (tester) async {
      bool tapped = false;

      final thread = DiscussionThreadEntity(
        id: 'thread-w-1',
        courseId: 'cs101',
        courseCode: 'CS101',
        courseTitle: 'Intro to Computer Science',
        title: 'How to implement Depth-First Search iteratively?',
        content: 'I want to avoid call stack overflow for deep graphs.',
        category: DiscussionCategory.homeworkHelp,
        authorId: 'student-01',
        authorName: 'Ada Lovelace',
        authorRole: 'Student',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPinned: false,
        isResolved: true,
        repliesCount: 4,
        replies: const [],
        tags: const ['Graphs', 'DFS'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscussionThreadCard(
              thread: thread,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('How to implement Depth-First Search iteratively?'), findsOneWidget);
      expect(find.text('4 replies'), findsOneWidget);
      expect(find.text('RESOLVED'), findsOneWidget);

      await tester.tap(find.byType(DiscussionThreadCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('DiscussionReplyCard renders verified solution and triggers upvote', (tester) async {
      bool upvoted = false;
      bool endorsed = false;

      final reply = DiscussionReplyEntity(
        id: 'reply-w-1',
        threadId: 'thread-w-1',
        authorId: 'inst-01',
        authorName: 'Prof. Alan Turing',
        authorRole: 'Faculty Instructor',
        content: 'Use an explicit List stack rather than function recursion.',
        createdAt: DateTime.now(),
        upvotes: 7,
        isInstructorEndorsed: true,
        upvotedByUserIds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiscussionReplyCard(
              reply: reply,
              currentUserId: 'student-01',
              isCurrentUserInstructor: true,
              onUpvote: () => upvoted = true,
              onToggleEndorsement: () => endorsed = true,
            ),
          ),
        ),
      );

      expect(find.text('VERIFIED FACULTY SOLUTION'), findsOneWidget);
      expect(find.text('Helpful (7)'), findsOneWidget);
      expect(find.text('Remove Endorsement'), findsOneWidget);

      await tester.tap(find.text('Helpful (7)'));
      await tester.pump();
      expect(upvoted, isTrue);

      await tester.tap(find.text('Remove Endorsement'));
      await tester.pump();
      expect(endorsed, isTrue);
    });

    testWidgets('NotificationBadgeButton displays unread count badge', (tester) async {
      final repository = CommunicationsRepositoryImpl(remoteDataSource: CommunicationsRemoteDataSourceImpl());
      final cubit = NotificationsCubit(repository: repository);
      cubit.emit(
        NotificationsLoaded(
          notifications: [
            NotificationEntity(
              id: 'notif-test-1',
              userId: 'demo-student-01',
              title: 'New Announcement',
              message: 'Prof. Turing posted an update',
              type: NotificationType.announcement,
              targetRoute: '/announcements',
              createdAt: DateTime.now(),
              isRead: false,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                BlocProvider<NotificationsCubit>.value(
                  value: cubit,
                  child: const NotificationBadgeButton(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await cubit.close();
    });
  });
}
