import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/courses/domain/entities/course_entity.dart';
import '../../features/courses/data/models/course_model.dart';
import '../../features/quizzes/data/models/quiz_model.dart';
import '../../features/quizzes/domain/entities/quiz_entity.dart';
import '../../features/communications/data/models/announcement_model.dart';
import '../../features/communications/domain/entities/announcement_entity.dart';
import '../../features/communications/data/models/discussion_model.dart';
import '../../features/communications/domain/entities/discussion_entity.dart';

/// Seeds the Firebase Firestore database with rich foundational academic data
/// if collections are empty upon application startup.
class FirebaseSeeder {
  FirebaseSeeder._();

  static bool _hasSeeded = false;

  /// Inspects foundational collections and populates them if currently empty.
  static Future<void> seedIfEmpty(FirebaseFirestore? firestore) async {
    if (firestore == null || _hasSeeded) return;
    _hasSeeded = true;

    try {
      await Future.wait([
        _seedCoursesIfEmpty(firestore),
        _seedQuizzesIfEmpty(firestore),
        _seedAnnouncementsIfEmpty(firestore),
        _seedDiscussionsIfEmpty(firestore),
      ]);
      developer.log('FirebaseSeeder: Verification and initial seeding completed.', name: 'FirebaseSeeder');
    } catch (e, st) {
      developer.log(
        'FirebaseSeeder: Non-fatal error during seeding: $e',
        name: 'FirebaseSeeder',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> _seedCoursesIfEmpty(FirebaseFirestore firestore) async {
    try {
      final snap = await firestore.collection('courses').limit(1).get();
      if (snap.docs.isNotEmpty) return;

      final batch = firestore.batch();
      final now = DateTime.now();

      final courses = [
        CourseModel(
          id: 'course-cs-301',
          code: 'CS-301',
          title: 'Data Structures & Algorithms',
          description:
              'Comprehensive study of fundamental data structures including trees, graphs, heaps, and algorithmic complexity analysis.',
          instructorId: 'demo-inst-01',
          instructorName: 'Dr. Sarah Jenkins',
          term: 'Fall 2026',
          department: 'Computer Science',
          credits: 4,
          schedule: 'Mon / Wed • 10:00 AM - 11:30 AM',
          room: 'Hall B-104',
          enrolledCount: 48,
          maxCapacity: 50,
          syllabus: const [
            SyllabusItem(
              weekNumber: 1,
              title: 'Algorithmic Complexity & Big-O Notation',
              description: 'Introduction to time and space asymptotic analysis.',
            ),
            SyllabusItem(
              weekNumber: 2,
              title: 'Linear Data Structures',
              description: 'Linked lists, doubly linked lists, stacks, and queues.',
            ),
            SyllabusItem(
              weekNumber: 3,
              title: 'Trees & Balanced Binary Search Trees',
              description: 'AVL trees, Red-Black trees, and tree traversal algorithms.',
            ),
            SyllabusItem(
              weekNumber: 4,
              title: 'Priority Queues & Binary Heaps',
              description: 'Heapify, Heapsort, and priority queue applications.',
            ),
          ],
          createdAt: now.subtract(const Duration(days: 30)),
        ),
        CourseModel(
          id: 'course-se-401',
          code: 'SE-401',
          title: 'Software Architecture & Design Patterns',
          description:
              'Enterprise application structures, SOLID principles, domain-driven design, microservices, and distributed cloud computing.',
          instructorId: 'demo-inst-01',
          instructorName: 'Dr. Sarah Jenkins',
          term: 'Fall 2026',
          department: 'Software Engineering',
          credits: 3,
          schedule: 'Friday • 09:00 AM - 12:00 PM',
          room: 'Auditorium 2',
          enrolledCount: 52,
          maxCapacity: 60,
          syllabus: const [
            SyllabusItem(
              weekNumber: 1,
              title: 'Object-Oriented Principles & SOLID',
              description: 'Encapsulation, abstraction, inheritance, and polymorphism.',
            ),
            SyllabusItem(
              weekNumber: 2,
              title: 'Creational & Structural Design Patterns',
              description: 'Factory, Singleton, Adapter, and Decorator patterns.',
            ),
            SyllabusItem(
              weekNumber: 3,
              title: 'Test-Driven Development & Clean Architecture',
              description: 'Unit testing, mocking, and repository patterns.',
            ),
          ],
          createdAt: now.subtract(const Duration(days: 20)),
        ),
        CourseModel(
          id: 'course-math-201',
          code: 'MATH-201',
          title: 'Linear Algebra & Numerical Methods',
          description:
              'Matrix operations, eigenvalues, eigenvectors, vector spaces, and numerical approximations for computational engineering.',
          instructorId: 'prof-math-02',
          instructorName: 'Prof. Alan Turing',
          term: 'Fall 2026',
          department: 'Mathematics',
          credits: 4,
          schedule: 'Mon / Wed • 08:30 AM - 10:00 AM',
          room: 'Euler Hall 101',
          enrolledCount: 42,
          maxCapacity: 50,
          syllabus: const [
            SyllabusItem(
              weekNumber: 1,
              title: 'Systems of Linear Equations',
              description: 'Gaussian elimination, row echelon forms, and rank.',
            ),
            SyllabusItem(
              weekNumber: 2,
              title: 'Vector Spaces & Subspaces',
              description: 'Basis, dimension, and linear transformations.',
            ),
          ],
          createdAt: now.subtract(const Duration(days: 15)),
        ),
      ];

      for (final course in courses) {
        final docRef = firestore.collection('courses').doc(course.id);
        batch.set(docRef, course.toMap());
      }
      await batch.commit();
      developer.log('FirebaseSeeder: Seeded foundational courses.', name: 'FirebaseSeeder');
    } catch (e) {
      developer.log('FirebaseSeeder: Failed to seed courses: $e', name: 'FirebaseSeeder');
    }
  }

  static Future<void> _seedQuizzesIfEmpty(FirebaseFirestore firestore) async {
    try {
      final snap = await firestore.collection('quizzes').limit(1).get();
      if (snap.docs.isNotEmpty) return;

      final now = DateTime.now();

      final q1 = QuizModel(
        id: 'quiz_cs101_1',
        courseId: 'course-cs-301',
        courseCode: 'CS-301',
        courseTitle: 'Data Structures & Algorithms',
        title: 'Quiz 1: Asymptotic Complexity & Big-O',
        description:
            'Evaluate your understanding of time & space complexities, master theorem, and recursive tree analysis.',
        timeLimitMinutes: 15,
        totalPoints: 30,
        passingPercentage: 70.0,
        maxAttempts: 2,
        isPublished: true,
        shuffleQuestions: true,
        allowReview: true,
        availableFrom: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 4)),
        questionsCount: 3,
      );

      final q2 = QuizModel(
        id: 'quiz_cs101_2',
        courseId: 'course-cs-301',
        courseCode: 'CS-301',
        courseTitle: 'Data Structures & Algorithms',
        title: 'Midterm Exam: Trees, Heaps & Graph Traversal',
        description:
            'Comprehensive midterm assessment covering binary search trees, AVL rotations, min/max heaps, and BFS/DFS traversal algorithms.',
        timeLimitMinutes: 45,
        totalPoints: 50,
        passingPercentage: 75.0,
        maxAttempts: 1,
        isPublished: true,
        shuffleQuestions: false,
        allowReview: true,
        availableFrom: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 6)),
        questionsCount: 4,
      );

      await firestore.collection('quizzes').doc(q1.id).set(q1.toJson());
      await firestore.collection('quizzes').doc(q2.id).set(q2.toJson());

      // Questions for q1
      final q1Questions = [
        const QuizQuestionModel(
          id: 'q_cs101_1_1',
          quizId: 'quiz_cs101_1',
          prompt: 'What is the tight worst-case time complexity of searching an element in an unsorted array of size N?',
          type: QuestionType.singleChoice,
          options: ['O(1)', 'O(log N)', 'O(N)', 'O(N^2)'],
          correctAnswer: 2,
          correctOptionIndices: [2],
          explanation: 'In an unsorted array, you may need to inspect all N elements sequentially.',
          points: 10,
        ),
        const QuizQuestionModel(
          id: 'q_cs101_1_2',
          quizId: 'quiz_cs101_1',
          prompt: 'True or False: An algorithm with time complexity O(N log N) is asymptotically faster than O(N^2).',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswer: true,
          correctOptionIndices: [0],
          explanation: 'For large N, N log N grows much more slowly than quadratic N^2.',
          points: 10,
        ),
        const QuizQuestionModel(
          id: 'q_cs101_1_3',
          quizId: 'quiz_cs101_1',
          prompt: 'Which algorithmic paradigm makes the locally optimal choice at each stage with the intent of finding a global optimum?',
          type: QuestionType.shortAnswer,
          options: [],
          correctAnswer: 'Greedy',
          correctOptionIndices: [],
          explanation: 'Greedy algorithms construct solutions piece-by-piece, always choosing the next piece that offers the most immediate benefit.',
          points: 10,
        ),
      ];

      for (final question in q1Questions) {
        await firestore
            .collection('quizzes')
            .doc(q1.id)
            .collection('questions')
            .doc(question.id)
            .set(question.toJson());
      }

      developer.log('FirebaseSeeder: Seeded foundational quizzes.', name: 'FirebaseSeeder');
    } catch (e) {
      developer.log('FirebaseSeeder: Failed to seed quizzes: $e', name: 'FirebaseSeeder');
    }
  }

  static Future<void> _seedAnnouncementsIfEmpty(FirebaseFirestore firestore) async {
    try {
      final snap = await firestore.collection('announcements').limit(1).get();
      if (snap.docs.isNotEmpty) return;

      final now = DateTime.now();
      final announcements = [
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
          courseId: 'all',
          courseCode: 'CAMPUS',
          courseTitle: 'Campus-Wide',
          title: 'Guest Lecture: Scalable Cloud Systems & Distributed Microservices at Google',
          content:
              'Join Principal Cloud Architect Elena Rostova this Thursday at 2:00 PM in Main Auditorium Hall A for a technical deep-dive into managing global-scale state synchronization, Spanner consensus, and Kubernetes clusters.',
          authorId: 'inst-02',
          authorName: 'Prof. David Thorne',
          authorRole: 'Department Chair',
          authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          priority: AnnouncementPriority.general,
          isPinned: false,
          publishedAt: now.subtract(const Duration(days: 2)),
          tags: const ['Guest Lecture', 'Cloud Computing', 'Computer Science'],
          readByStudentIds: const [],
        ),
      ];

      for (final ann in announcements) {
        await firestore.collection('announcements').doc(ann.id).set(ann.toJson());
      }
      developer.log('FirebaseSeeder: Seeded foundational announcements.', name: 'FirebaseSeeder');
    } catch (e) {
      developer.log('FirebaseSeeder: Failed to seed announcements: $e', name: 'FirebaseSeeder');
    }
  }

  static Future<void> _seedDiscussionsIfEmpty(FirebaseFirestore firestore) async {
    try {
      final snap = await firestore.collection('discussions').limit(1).get();
      if (snap.docs.isNotEmpty) return;

      final now = DateTime.now();
      final thread1 = DiscussionThreadModel(
        id: 'thread-1',
        courseId: 'course-cs-301',
        courseCode: 'CS-301',
        courseTitle: 'Data Structures & Algorithms',
        title: 'Dynamic Programming vs Divide-and-Conquer: Overlapping Subproblems',
        content:
            'Can someone clearly explain the core distinction between optimal substructure in Divide-and-Conquer versus Dynamic Programming? Merge Sort divides problems into independent halves, whereas Fibonacci or Shortest Paths have overlapping subproblems. How does memoization prevent recomputation exponential blow-up?',
        authorId: 'stu-01',
        authorName: 'Alex Mercer',
        authorRole: 'Student',
        authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
        category: DiscussionCategory.technicalQuestions,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 3)),
        repliesCount: 2,
        isPinned: true,
        tags: const ['Dynamic Programming', 'Complexity', 'Algorithms'],
      );

      await firestore.collection('discussions').doc(thread1.id).set(thread1.toJson());

      final reply1 = DiscussionReplyModel(
        id: 'reply-1-1',
        threadId: 'thread-1',
        authorId: 'inst-01',
        authorName: 'Dr. Sarah Connor',
        authorRole: 'Course Instructor',
        authorAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2',
        content:
            'Excellent question, Alex! The key discriminator is "subproblem independence". In Divide-and-Conquer (like MergeSort), subproblems never overlap; you divide and conquer disjoint sets. In Dynamic Programming, multiple recursion branches demand solutions to the exact same subproblem instances (e.g. fib(n-1) and fib(n-2) both need fib(n-2)). Memoization caches the evaluated results in a lookup table, transforming O(2^N) exponential trees into linear O(N) DAG evaluations.',
        createdAt: now.subtract(const Duration(days: 1)),
        upvotes: 14,
        isInstructorEndorsed: true,
        upvotedByUserIds: const ['stu-01', 'stu-02'],
      );

      await firestore
          .collection('discussions')
          .doc(thread1.id)
          .collection('replies')
          .doc(reply1.id)
          .set(reply1.toJson());

      developer.log('FirebaseSeeder: Seeded foundational discussions.', name: 'FirebaseSeeder');
    } catch (e) {
      developer.log('FirebaseSeeder: Failed to seed discussions: $e', name: 'FirebaseSeeder');
    }
  }
}
