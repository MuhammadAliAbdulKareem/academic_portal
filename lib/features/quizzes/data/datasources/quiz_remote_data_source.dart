import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../models/quiz_model.dart';
import '../../domain/entities/quiz_entity.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuizModel>> getAllQuizzes({String? courseId, String? studentId});
  Future<List<QuizModel>> getCourseQuizzes(String courseId);
  Future<QuizModel> getQuizById(String quizId);
  Future<List<QuizQuestionModel>> getQuizQuestions(String quizId);
  Future<QuizModel> createQuiz(QuizModel quiz, List<QuizQuestionModel> questions);
  Future<QuizModel> updateQuiz(QuizModel quiz);
  Future<void> deleteQuiz(String quizId);
  Future<QuizAttemptModel> startQuizAttempt({
    required String quizId,
    required String studentId,
    required String studentName,
    String? studentAvatar,
  });
  Future<QuizAttemptModel> submitQuizAttempt({
    required String attemptId,
    required Map<String, dynamic> answers,
  });
  Future<List<QuizAttemptModel>> getStudentQuizAttempts({
    required String quizId,
    required String studentId,
  });
  Future<List<QuizAttemptModel>> getQuizRosterAttempts(String quizId);
  Future<QuizSummaryStatsModel> getQuizStats(String quizId);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final FirebaseFirestore? _firestore;
  final List<QuizModel> _quizzes = [];
  final Map<String, List<QuizQuestionModel>> _questions = {};
  final List<QuizAttemptModel> _attempts = [];

  QuizRemoteDataSourceImpl({FirebaseFirestore? firestore}) : _firestore = firestore {
    _seedData();
  }

  bool get _isFirebaseReady => FirebaseConfig.isInitialized && _firestore != null;

  void _seedData() {
    final now = DateTime.now();

    // 1. Quizzes
    final q1 = QuizModel(
      id: 'quiz_cs101_1',
      courseId: 'course_cs101',
      courseCode: 'CS101',
      courseTitle: 'Introduction to Computer Science & Algorithms',
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
      courseId: 'course_cs101',
      courseCode: 'CS101',
      courseTitle: 'Introduction to Computer Science & Algorithms',
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

    final q3 = QuizModel(
      id: 'quiz_cs201_1',
      courseId: 'course_cs201',
      courseCode: 'CS201',
      courseTitle: 'Data Structures and Algorithms',
      title: 'Quiz 2: Relational Normalization & ACID Properties',
      description:
          'Assessment on Boyce-Codd Normal Form (BCNF), 3NF functional dependencies, and database isolation levels.',
      timeLimitMinutes: 20,
      totalPoints: 40,
      passingPercentage: 65.0,
      maxAttempts: 2,
      isPublished: true,
      shuffleQuestions: true,
      allowReview: true,
      availableFrom: now.subtract(const Duration(days: 5)),
      dueDate: now.add(const Duration(days: 2)),
      questionsCount: 3,
    );

    final q4 = QuizModel(
      id: 'quiz_math301_1',
      courseId: 'course_math301',
      courseCode: 'MATH301',
      courseTitle: 'Linear Algebra & Applications',
      title: 'Quiz 1: Vector Spaces & Linear Independence',
      description:
          'Test on subspaces, span, linear independence, basis, dimension, and rank-nullity theorem.',
      timeLimitMinutes: 30,
      totalPoints: 40,
      passingPercentage: 70.0,
      maxAttempts: 1,
      isPublished: true,
      shuffleQuestions: false,
      allowReview: true,
      availableFrom: now.subtract(const Duration(days: 2)),
      dueDate: now.add(const Duration(days: 5)),
      questionsCount: 3,
    );

    _quizzes.addAll([q1, q2, q3, q4]);

    // 2. Questions for quiz_cs101_1
    _questions['quiz_cs101_1'] = [
      const QuizQuestionModel(
        id: 'q_cs101_1_1',
        quizId: 'quiz_cs101_1',
        prompt:
            'What is the worst-case time complexity of searching for an element in a balanced Binary Search Tree (AVL tree) containing N nodes?',
        type: QuestionType.singleChoice,
        options: [
          'O(1)',
          'O(log N)',
          'O(N)',
          'O(N log N)',
        ],
        correctAnswer: 1,
        correctOptionIndices: [1],
        explanation:
            'In a balanced binary search tree with height bounded by log2(N), searching requires traversing at most height levels, giving O(log N) worst-case time.',
        points: 10,
      ),
      const QuizQuestionModel(
        id: 'q_cs101_1_2',
        quizId: 'quiz_cs101_1',
        prompt:
            'True or False: A recursive function without a properly defined base condition will eventually cause a Stack Overflow exception.',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctAnswer: true,
        correctOptionIndices: [0],
        explanation:
            'Without a terminating base case, recursive stack frames continue allocating call contexts until memory limit is exhausted.',
        points: 10,
      ),
      const QuizQuestionModel(
        id: 'q_cs101_1_3',
        quizId: 'quiz_cs101_1',
        prompt:
            'Which algorithmic paradigm does Merge Sort utilize to achieve O(N log N) sorting? (e.g. Greedy, Dynamic Programming, Divide and Conquer)',
        type: QuestionType.shortAnswer,
        options: [],
        correctAnswer: 'Divide and Conquer',
        correctOptionIndices: [],
        explanation:
            'Merge Sort recursively divides the unsorted list into halves (Divide), sorts each sub-array (Conquer), and merges sorted halves (Combine).',
        points: 10,
      ),
    ];

    // Questions for quiz_cs101_2
    _questions['quiz_cs101_2'] = [
      const QuizQuestionModel(
        id: 'q_cs101_2_1',
        quizId: 'quiz_cs101_2',
        prompt:
            'Which data structure is typically used to implement Breadth-First Search (BFS) on an unweighted graph?',
        type: QuestionType.singleChoice,
        options: [
          'Stack (LIFO)',
          'Queue (FIFO)',
          'Priority Queue',
          'Hash Table',
        ],
        correctAnswer: 1,
        correctOptionIndices: [1],
        explanation:
            'BFS visits nodes level by level in First-In-First-Out order, naturally requiring a FIFO Queue.',
        points: 10,
      ),
      const QuizQuestionModel(
        id: 'q_cs101_2_2',
        quizId: 'quiz_cs101_2',
        prompt:
            'Which of the following operations have O(1) average time complexity in a well-distributed Hash Table? (Select all that apply)',
        type: QuestionType.multipleChoice,
        options: [
          'Insertion (put)',
          'Lookup by Key (get)',
          'Deletion by Key (remove)',
          'Sorting all keys in ascending order',
        ],
        correctAnswer: null,
        correctOptionIndices: [0, 1, 2],
        explanation:
            'Direct hash table key operations (insert, lookup, delete) take O(1) average time. Sorting requires extracting and sorting keys in O(N log N).',
        points: 15,
      ),
      const QuizQuestionModel(
        id: 'q_cs101_2_3',
        quizId: 'quiz_cs101_2',
        prompt:
            'In a Min-Heap of size N, what is the time complexity of extracting the minimum element?',
        type: QuestionType.singleChoice,
        options: [
          'O(1)',
          'O(log N)',
          'O(N)',
          'O(N^2)',
        ],
        correctAnswer: 1,
        correctOptionIndices: [1],
        explanation:
            'Retrieving the root is O(1), but restoring the heap invariant by bubbling down takes O(log N).',
        points: 10,
      ),
      const QuizQuestionModel(
        id: 'q_cs101_2_4',
        quizId: 'quiz_cs101_2',
        prompt:
            'True or False: Depth-First Search (DFS) is guaranteed to find the shortest path between two nodes in an unweighted graph.',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctAnswer: false,
        correctOptionIndices: [1],
        explanation:
            'False. BFS guarantees finding the shortest path in unweighted graphs because it expands search frontiers equidistant from the start. DFS may take long, winding paths.',
        points: 15,
      ),
    ];

    // Questions for quiz_cs201_1
    _questions['quiz_cs201_1'] = [
      const QuizQuestionModel(
        id: 'q_cs201_1_1',
        quizId: 'quiz_cs201_1',
        prompt:
            'A table is in Third Normal Form (3NF) if it is in 2NF and contains no:',
        type: QuestionType.singleChoice,
        options: [
          'Primary keys',
          'Transitive functional dependencies',
          'Foreign keys',
          'Composite attributes',
        ],
        correctAnswer: 1,
        correctOptionIndices: [1],
        explanation:
            '3NF prohibits non-prime attributes from depending transitively on superkeys.',
        points: 15,
      ),
      const QuizQuestionModel(
        id: 'q_cs201_1_2',
        quizId: 'quiz_cs201_1',
        prompt:
            'What does the "I" stand for in the database ACID transaction properties?',
        type: QuestionType.shortAnswer,
        options: [],
        correctAnswer: 'Isolation',
        correctOptionIndices: [],
        explanation:
            'ACID stands for Atomicity, Consistency, Isolation, and Durability.',
        points: 10,
      ),
      const QuizQuestionModel(
        id: 'q_cs201_1_3',
        quizId: 'quiz_cs201_1',
        prompt:
            'True or False: An INNER JOIN returns only the rows where there is a match in both joined tables.',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctAnswer: true,
        correctOptionIndices: [0],
        explanation:
            'An INNER JOIN filters out unmatched records from either table.',
        points: 15,
      ),
    ];

    // Questions for quiz_math301_1
    _questions['quiz_math301_1'] = [
      const QuizQuestionModel(
        id: 'q_math301_1_1',
        quizId: 'quiz_math301_1',
        prompt:
            'If the determinant of a square matrix A is zero (det(A) = 0), what does this imply about the matrix?',
        type: QuestionType.singleChoice,
        options: [
          'The matrix is invertible',
          'The matrix is singular (not invertible)',
          'All eigenvalues are strictly positive',
          'The matrix is symmetric',
        ],
        correctAnswer: 1,
        correctOptionIndices: [1],
        explanation:
            'A zero determinant implies linearly dependent columns/rows, rendering the matrix non-invertible (singular).',
        points: 15,
      ),
      const QuizQuestionModel(
        id: 'q_math301_1_2',
        quizId: 'quiz_math301_1',
        prompt:
            'True or False: The zero vector must always belong to any valid vector subspace.',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctAnswer: true,
        correctOptionIndices: [0],
        explanation:
            'By definition, a vector subspace must contain the zero vector and be closed under vector addition and scalar multiplication.',
        points: 10,
      ),
      const QuizQuestionModel(
        id: 'q_math301_1_3',
        quizId: 'quiz_math301_1',
        prompt:
            'What is the dimension of the vector space R^4 over the real numbers?',
        type: QuestionType.singleChoice,
        options: ['2', '3', '4', 'Infinite'],
        correctAnswer: 2,
        correctOptionIndices: [2],
        explanation:
            'The standard basis for R^4 has 4 basis vectors, hence its dimension is 4.',
        points: 15,
      ),
    ];

    // 3. Pre-seeded attempts
    _attempts.addAll([
      QuizAttemptModel(
        id: 'attempt_1',
        quizId: 'quiz_cs101_1',
        studentId: 'student_1',
        studentName: 'Sarah Jenkins',
        studentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        startedAt: now.subtract(const Duration(days: 2, hours: 3)),
        submittedAt: now.subtract(const Duration(days: 2, hours: 2, minutes: 48)),
        answers: {
          'q_cs101_1_1': 1,
          'q_cs101_1_2': true,
          'q_cs101_1_3': 'divide and conquer',
        },
        score: 30,
        totalPossiblePoints: 30,
        percentage: 100.0,
        passed: true,
        isAutoGraded: true,
        feedback: 'Flawless attempt! Complete conceptual clarity.',
      ),
      QuizAttemptModel(
        id: 'attempt_2',
        quizId: 'quiz_cs101_1',
        studentId: 'student_2',
        studentName: 'Alex Rivera',
        studentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        startedAt: now.subtract(const Duration(days: 1, hours: 5)),
        submittedAt: now.subtract(const Duration(days: 1, hours: 4, minutes: 46)),
        answers: {
          'q_cs101_1_1': 2,
          'q_cs101_1_2': true,
          'q_cs101_1_3': 'divide and conquer',
        },
        score: 20,
        totalPossiblePoints: 30,
        percentage: 66.7,
        passed: false,
        isAutoGraded: true,
        feedback: 'Good effort. Review logarithmic search trees.',
      ),
      QuizAttemptModel(
        id: 'attempt_3',
        quizId: 'quiz_cs101_1',
        studentId: 'student_3',
        studentName: 'David Kim',
        studentAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        startedAt: now.subtract(const Duration(hours: 12)),
        submittedAt: now.subtract(const Duration(hours: 11, minutes: 47)),
        answers: {
          'q_cs101_1_1': 1,
          'q_cs101_1_2': true,
          'q_cs101_1_3': 'greedy',
        },
        score: 20,
        totalPossiblePoints: 30,
        percentage: 66.7,
        passed: false,
        isAutoGraded: true,
        feedback: 'Solid knowledge on trees and recursion.',
      ),
    ]);
  }

  @override
  Future<List<QuizModel>> getAllQuizzes({String? courseId, String? studentId}) async {
    if (_isFirebaseReady) {
      try {
        Query<Map<String, dynamic>> query = _firestore!.collection('quizzes');
        if (courseId != null && courseId.isNotEmpty) {
          query = query.where('courseId', isEqualTo: courseId);
        }
        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => QuizModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<QuizModel>.from(_quizzes);
    if (courseId != null && courseId.isNotEmpty) {
      results = results.where((q) => q.courseId == courseId).toList();
    }
    return results;
  }

  @override
  Future<List<QuizModel>> getCourseQuizzes(String courseId) async {
    return getAllQuizzes(courseId: courseId);
  }

  @override
  Future<QuizModel> getQuizById(String quizId) async {
    if (_isFirebaseReady) {
      try {
        final doc = await _firestore!.collection('quizzes').doc(quizId).get();
        if (doc.exists && doc.data() != null) {
          return QuizModel.fromJson({...doc.data()!, 'id': doc.id});
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final index = _quizzes.indexWhere((q) => q.id == quizId);
    if (index == -1) {
      throw Exception('Quiz not found: $quizId');
    }
    return _quizzes[index];
  }

  @override
  Future<List<QuizQuestionModel>> getQuizQuestions(String quizId) async {
    if (_isFirebaseReady) {
      try {
        final snap = await _firestore!
            .collection('quizzes')
            .doc(quizId)
            .collection('questions')
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => QuizQuestionModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final list = _questions[quizId] ?? [];
    return List<QuizQuestionModel>.from(list);
  }

  @override
  Future<QuizModel> createQuiz(QuizModel quiz, List<QuizQuestionModel> questions) async {
    final newId = quiz.id.isNotEmpty ? quiz.id : 'quiz_${DateTime.now().millisecondsSinceEpoch}';
    final computedPoints = questions.fold<int>(0, (total, q) => total + q.points);
    final newQuiz = quiz.copyWith(
      id: newId,
      totalPoints: computedPoints > 0 ? computedPoints : quiz.totalPoints,
      questionsCount: questions.length,
    );
    final model = QuizModel.fromEntity(newQuiz);

    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('quizzes').doc(newId).set(model.toJson());
        final batch = _firestore.batch();
        for (final q in questions) {
          final qId = q.id.isNotEmpty
              ? q.id
              : 'q_${DateTime.now().millisecondsSinceEpoch}_${questions.indexOf(q)}';
          final mappedQ = q.copyWith(id: qId, quizId: newId);
          final ref = _firestore
              .collection('quizzes')
              .doc(newId)
              .collection('questions')
              .doc(qId);
          batch.set(ref, QuizQuestionModel.fromEntity(mappedQ).toJson());
        }
        await batch.commit();
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 250));
    _quizzes.insert(0, model);

    final mappedQuestions = questions
        .map((q) => q.copyWith(quizId: newId))
        .map(QuizQuestionModel.fromEntity)
        .toList();
    _questions[newId] = mappedQuestions;
    return model;
  }

  @override
  Future<QuizModel> updateQuiz(QuizModel quiz) async {
    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('quizzes').doc(quiz.id).set(quiz.toJson());
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    final index = _quizzes.indexWhere((q) => q.id == quiz.id);
    if (index != -1) {
      _quizzes[index] = quiz;
    }
    return quiz;
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('quizzes').doc(quizId).delete();
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    _quizzes.removeWhere((q) => q.id == quizId);
    _questions.remove(quizId);
    _attempts.removeWhere((a) => a.quizId == quizId);
  }

  @override
  Future<QuizAttemptModel> startQuizAttempt({
    required String quizId,
    required String studentId,
    required String studentName,
    String? studentAvatar,
  }) async {
    final quiz = await getQuizById(quizId);
    final existingAttempts = await getStudentQuizAttempts(quizId: quizId, studentId: studentId);
    if (existingAttempts.length >= quiz.maxAttempts) {
      throw Exception('Maximum attempts (${quiz.maxAttempts}) reached for this quiz.');
    }

    final newAttempt = QuizAttemptModel(
      id: 'attempt_${DateTime.now().millisecondsSinceEpoch}',
      quizId: quizId,
      studentId: studentId,
      studentName: studentName,
      studentAvatar: studentAvatar,
      startedAt: DateTime.now(),
      score: 0,
      totalPossiblePoints: quiz.totalPoints,
      percentage: 0.0,
      passed: false,
      isAutoGraded: false,
    );

    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('quiz_attempts').doc(newAttempt.id).set(newAttempt.toJson());
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _attempts.add(newAttempt);
    return newAttempt;
  }

  @override
  Future<QuizAttemptModel> submitQuizAttempt({
    required String attemptId,
    required Map<String, dynamic> answers,
  }) async {
    QuizAttemptModel? currentAttempt =
        _attempts.where((a) => a.id == attemptId).firstOrNull;

    if (currentAttempt == null && _isFirebaseReady) {
      try {
        final doc = await _firestore!.collection('quiz_attempts').doc(attemptId).get();
        if (doc.exists && doc.data() != null) {
          currentAttempt = QuizAttemptModel.fromJson({...doc.data()!, 'id': doc.id});
        }
      } catch (_) {}
    }

    if (currentAttempt == null) {
      throw Exception('Attempt not found: $attemptId');
    }

    final quiz = await getQuizById(currentAttempt.quizId);
    final questions = await getQuizQuestions(currentAttempt.quizId);

    int totalEarned = 0;
    int maxPoints = 0;

    for (final q in questions) {
      maxPoints += q.points;
      final studentAns = answers[q.id];
      if (q.isAnswerCorrect(studentAns)) {
        totalEarned += q.points;
      }
    }

    if (maxPoints == 0) maxPoints = quiz.totalPoints > 0 ? quiz.totalPoints : 100;
    final percentage = (totalEarned / maxPoints) * 100.0;
    final passed = percentage >= quiz.passingPercentage;

    final updated = currentAttempt.copyWith(
      submittedAt: DateTime.now(),
      answers: answers,
      score: totalEarned,
      totalPossiblePoints: maxPoints,
      percentage: double.parse(percentage.toStringAsFixed(1)),
      passed: passed,
      isAutoGraded: true,
      feedback: passed
          ? 'Great job! You met the passing criteria of ${quiz.passingPercentage.toStringAsFixed(0)}%.'
          : 'Score below passing mark (${quiz.passingPercentage.toStringAsFixed(0)}%). Review question explanations to improve.',
    );

    final updatedModel = QuizAttemptModel.fromEntity(updated);

    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('quiz_attempts').doc(updatedModel.id).set(updatedModel.toJson());
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final index = _attempts.indexWhere((a) => a.id == attemptId);
    if (index != -1) {
      _attempts[index] = updatedModel;
    } else {
      _attempts.add(updatedModel);
    }
    return updatedModel;
  }

  @override
  Future<List<QuizAttemptModel>> getStudentQuizAttempts({
    required String quizId,
    required String studentId,
  }) async {
    if (_isFirebaseReady) {
      try {
        final snap = await _firestore!
            .collection('quiz_attempts')
            .where('quizId', isEqualTo: quizId)
            .where('studentId', isEqualTo: studentId)
            .get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs
              .map((d) => QuizAttemptModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
          list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return list;
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 100));
    return _attempts
        .where((a) => a.quizId == quizId && a.studentId == studentId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<List<QuizAttemptModel>> getQuizRosterAttempts(String quizId) async {
    if (_isFirebaseReady) {
      try {
        final snap = await _firestore!
            .collection('quiz_attempts')
            .where('quizId', isEqualTo: quizId)
            .get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs
              .map((d) => QuizAttemptModel.fromJson({...d.data(), 'id': d.id}))
              .toList();
          list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return list;
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    return _attempts.where((a) => a.quizId == quizId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  @override
  Future<QuizSummaryStatsModel> getQuizStats(String quizId) async {
    final attempts = (await getQuizRosterAttempts(quizId)).where((a) => a.isCompleted).toList();
    if (attempts.isEmpty) {
      return QuizSummaryStatsModel(
        quizId: quizId,
        totalSubmissions: 0,
        averageScore: 0.0,
        highestScore: 0,
        lowestScore: 0,
        passRatePercentage: 0.0,
      );
    }

    final total = attempts.length;
    final scores = attempts.map((a) => a.score).toList();
    final avg = scores.reduce((a, b) => a + b) / total;
    final highest = scores.reduce((a, b) => a > b ? a : b);
    final lowest = scores.reduce((a, b) => a < b ? a : b);
    final passedCount = attempts.where((a) => a.passed).length;
    final passRate = (passedCount / total) * 100.0;

    return QuizSummaryStatsModel(
      quizId: quizId,
      totalSubmissions: total,
      averageScore: double.parse(avg.toStringAsFixed(1)),
      highestScore: highest,
      lowestScore: lowest,
      passRatePercentage: double.parse(passRate.toStringAsFixed(1)),
    );
  }
}
