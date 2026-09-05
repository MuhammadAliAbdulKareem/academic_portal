import 'package:academic_portal/features/quizzes/data/datasources/quiz_remote_data_source.dart';
import 'package:academic_portal/features/quizzes/data/repositories/quiz_repository_impl.dart';
import 'package:academic_portal/features/quizzes/domain/entities/quiz_entity.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_analytics_cubit.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_analytics_state.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_builder_cubit.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_builder_state.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_exam_session_cubit.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_exam_session_state.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_list_cubit.dart';
import 'package:academic_portal/features/quizzes/presentation/cubit/quiz_list_state.dart';
import 'package:academic_portal/features/quizzes/presentation/widgets/exam_timer_widget.dart';
import 'package:academic_portal/features/quizzes/presentation/widgets/question_palette_widget.dart';
import 'package:academic_portal/features/quizzes/presentation/widgets/question_view_card.dart';
import 'package:academic_portal/features/quizzes/presentation/widgets/quiz_card.dart';
import 'package:academic_portal/features/quizzes/presentation/widgets/quiz_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quiz Domain Entities & Logic Tests', () {
    test('QuizQuestionEntity evaluates answers correctly across all question types', () {
      // Single choice
      const singleQ = QuizQuestionEntity(
        id: 'q1',
        quizId: 'quiz1',
        prompt: 'Select capital of France',
        type: QuestionType.singleChoice,
        options: ['London', 'Paris', 'Berlin'],
        correctAnswer: 1,
        points: 10,
      );
      expect(singleQ.isAnswerCorrect(1), isTrue);
      expect(singleQ.isAnswerCorrect(0), isFalse);
      expect(singleQ.isAnswerCorrect(null), isFalse);

      // True/False
      const tfQ = QuizQuestionEntity(
        id: 'q2',
        quizId: 'quiz1',
        prompt: 'Flutter is cross-platform',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctAnswer: true,
        points: 5,
      );
      expect(tfQ.isAnswerCorrect(true), isTrue);
      expect(tfQ.isAnswerCorrect(false), isFalse);

      // Multiple choice
      const multiQ = QuizQuestionEntity(
        id: 'q3',
        quizId: 'quiz1',
        prompt: 'Select even numbers',
        type: QuestionType.multipleChoice,
        options: ['1', '2', '3', '4'],
        correctOptionIndices: [1, 3],
        points: 10,
      );
      expect(multiQ.isAnswerCorrect([1, 3]), isTrue);
      expect(multiQ.isAnswerCorrect([3, 1]), isTrue);
      expect(multiQ.isAnswerCorrect([1]), isFalse);

      // Short answer
      const shortQ = QuizQuestionEntity(
        id: 'q4',
        quizId: 'quiz1',
        prompt: 'Name of the Flutter language',
        type: QuestionType.shortAnswer,
        correctAnswer: 'Dart',
        points: 10,
      );
      expect(shortQ.isAnswerCorrect('Dart'), isTrue);
      expect(shortQ.isAnswerCorrect('dart '), isTrue);
      expect(shortQ.isAnswerCorrect('Java'), isFalse);
    });

    test('QuizEntity calculates availability and formatted time limit', () {
      final now = DateTime.now();
      final quiz = QuizEntity(
        id: 'quiz_test',
        courseId: 'c1',
        courseCode: 'CS101',
        courseTitle: 'Intro to CS',
        title: 'Algorithms Test',
        description: 'Testing',
        timeLimitMinutes: 45,
        totalPoints: 100,
        passingPercentage: 70.0,
        availableFrom: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 5)),
        questionsCount: 10,
      );

      expect(quiz.isAvailable, isTrue);
      expect(quiz.isExpired, isFalse);
      expect(quiz.timeLimitFormatted, equals('45 Mins'));

      final expiredQuiz = quiz.copyWith(
        availableFrom: now.subtract(const Duration(days: 10)),
        dueDate: now.subtract(const Duration(days: 2)),
      );
      expect(expiredQuiz.isExpired, isTrue);
      expect(expiredQuiz.isAvailable, isFalse);
    });

    test('QuizAttemptEntity computes duration and pass/fail state', () {
      final started = DateTime(2026, 9, 6, 10, 0);
      final submitted = DateTime(2026, 9, 6, 10, 24, 30);
      final attempt = QuizAttemptEntity(
        id: 'att_1',
        quizId: 'q1',
        studentId: 's1',
        studentName: 'Alice',
        startedAt: started,
        submittedAt: submitted,
        score: 85,
        totalPossiblePoints: 100,
        percentage: 85.0,
        passed: true,
      );

      expect(attempt.isCompleted, isTrue);
      expect(attempt.timeTakenFormatted, equals('24m 30s'));
      expect(attempt.passed, isTrue);
    });
  });

  group('Quiz Data Layer & Repository Tests', () {
    late QuizRemoteDataSourceImpl dataSource;
    late QuizRepositoryImpl repository;

    setUp(() {
      dataSource = QuizRemoteDataSourceImpl();
      repository = QuizRepositoryImpl(remoteDataSource: dataSource);
    });

    test('getAllQuizzes retrieves seeded quizzes and filters by course', () async {
      final all = await repository.getAllQuizzes();
      expect(all.length, greaterThanOrEqualTo(4));

      final cs101 = await repository.getCourseQuizzes('course_cs101');
      expect(cs101.every((q) => q.courseId == 'course_cs101'), isTrue);
    });

    test('startQuizAttempt and submitQuizAttempt calculates score automatically', () async {
      final attempt = await repository.startQuizAttempt(
        quizId: 'quiz_cs101_1',
        studentId: 'student_tester',
        studentName: 'Tester Student',
      );
      expect(attempt.quizId, equals('quiz_cs101_1'));
      expect(attempt.studentId, equals('student_tester'));

      final submitted = await repository.submitQuizAttempt(
        attemptId: attempt.id,
        answers: {
          'q_cs101_1_1': 1, // correct: 10 pts
          'q_cs101_1_2': true, // correct: 10 pts
          'q_cs101_1_3': 'divide and conquer', // correct: 10 pts
        },
      );

      expect(submitted.isCompleted, isTrue);
      expect(submitted.score, equals(30));
      expect(submitted.totalPossiblePoints, equals(30));
      expect(submitted.percentage, equals(100.0));
      expect(submitted.passed, isTrue);
    });

    test('getQuizStats calculates pass rate and averages', () async {
      final stats = await repository.getQuizStats('quiz_cs101_1');
      expect(stats.totalSubmissions, greaterThanOrEqualTo(3));
      expect(stats.averageScore, greaterThan(0));
    });
  });

  group('Quiz State Management Cubit Tests', () {
    late QuizRemoteDataSourceImpl dataSource;
    late QuizRepositoryImpl repository;

    setUp(() {
      dataSource = QuizRemoteDataSourceImpl();
      repository = QuizRepositoryImpl(remoteDataSource: dataSource);
    });

    test('QuizListCubit loads, searches, and filters quizzes', () async {
      final cubit = QuizListCubit(repository: repository);
      await cubit.loadQuizzes();

      expect(cubit.state, isA<QuizListLoaded>());
      final loaded = cubit.state as QuizListLoaded;
      expect(loaded.allQuizzes.isNotEmpty, isTrue);

      cubit.searchQuizzes('Big-O');
      final searchResult = cubit.state as QuizListLoaded;
      expect(searchResult.filteredQuizzes.length, equals(1));
      expect(searchResult.filteredQuizzes.first.title.contains('Big-O'), isTrue);

      cubit.searchQuizzes('');
      cubit.filterByCourse('course_math301');
      final courseResult = cubit.state as QuizListLoaded;
      expect(courseResult.filteredQuizzes.every((q) => q.courseId == 'course_math301'), isTrue);

      await cubit.close();
    });

    test('QuizExamSessionCubit runs exam workflow, stages answers, flags and submits', () async {
      final cubit = QuizExamSessionCubit(repository: repository);

      await cubit.startSession(
        quizId: 'quiz_cs101_1',
        studentId: 'test_student_exam',
        studentName: 'Exam Taker',
      );

      expect(cubit.state, isA<QuizExamSessionActive>());
      final active = cubit.state as QuizExamSessionActive;
      expect(active.questions.length, equals(3));
      expect(active.remainingSeconds, greaterThan(0));

      final q1Id = active.questions[0].id;
      cubit.selectAnswer(q1Id, 1);
      cubit.toggleFlagQuestion(q1Id);

      var stateNow = cubit.state as QuizExamSessionActive;
      expect(stateNow.answers[q1Id], equals(1));
      expect(stateNow.isQuestionFlagged(q1Id), isTrue);

      cubit.nextQuestion();
      stateNow = cubit.state as QuizExamSessionActive;
      expect(stateNow.currentQuestionIndex, equals(1));

      await cubit.submitExam();
      expect(cubit.state, isA<QuizExamSessionSubmitted>());
      final submitted = cubit.state as QuizExamSessionSubmitted;
      expect(submitted.attempt.isCompleted, isTrue);

      await cubit.close();
    });

    test('QuizBuilderCubit adds, validates, and creates quizzes', () async {
      final cubit = QuizBuilderCubit(repository: repository);
      cubit.initNewQuiz();

      expect(cubit.state, isA<QuizBuilderEditing>());
      var editing = cubit.state as QuizBuilderEditing;
      expect(editing.questions.isEmpty, isTrue);

      // Attempting to save empty quiz triggers validation error
      await cubit.saveQuiz();
      expect(cubit.state, isA<QuizBuilderEditing>());

      cubit.updateBasicDetails(
        title: 'New Automated Quiz',
        description: 'Auto test quiz',
      );

      cubit.addQuestion(const QuizQuestionEntity(
        id: 'new_q1',
        quizId: '',
        prompt: 'Sample test question',
        type: QuestionType.singleChoice,
        options: ['A', 'B'],
        correctAnswer: 0,
        points: 25,
      ));

      editing = cubit.state as QuizBuilderEditing;
      expect(editing.computedTotalPoints, equals(25));
      expect(editing.questions.length, equals(1));

      await cubit.saveQuiz();
      expect(cubit.state, isA<QuizBuilderSaved>());

      await cubit.close();
    });

    test('QuizAnalyticsCubit loads statistics and filters roster', () async {
      final cubit = QuizAnalyticsCubit(repository: repository);
      await cubit.loadAnalytics('quiz_cs101_1');

      expect(cubit.state, isA<QuizAnalyticsLoaded>());
      final loaded = cubit.state as QuizAnalyticsLoaded;
      expect(loaded.stats.totalSubmissions, greaterThanOrEqualTo(3));
      expect(loaded.allAttempts.length, greaterThanOrEqualTo(3));

      cubit.filterStudentSearch('Sarah');
      final filtered = cubit.state as QuizAnalyticsLoaded;
      expect(filtered.filteredAttempts.length, equals(1));
      expect(filtered.filteredAttempts.first.studentName.contains('Sarah'), isTrue);

      await cubit.close();
    });
  });

  group('Quiz Presentation Widgets Tests', () {
    testWidgets('QuizCard renders title, course badge, points, and start action', (tester) async {
      bool tappedStart = false;

      final testQuiz = QuizEntity(
        id: 'card_quiz_1',
        courseId: 'c1',
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        title: 'Asymptotic Analysis Mastery',
        description: 'Test your understanding of Big-O notations and limits.',
        timeLimitMinutes: 20,
        totalPoints: 50,
        availableFrom: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 3)),
        questionsCount: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: testQuiz,
              onTakeQuiz: () => tappedStart = true,
            ),
          ),
        ),
      );

      expect(find.text('CS101'), findsOneWidget);
      expect(find.text('Asymptotic Analysis Mastery'), findsOneWidget);
      expect(find.text('20 Mins'), findsOneWidget);
      expect(find.text('5 Questions'), findsOneWidget);
      expect(find.text('50 Pts'), findsOneWidget);
      expect(find.text('Start Quiz'), findsOneWidget);

      await tester.tap(find.text('Start Quiz'));
      await tester.pump();
      expect(tappedStart, isTrue);
    });

    testWidgets('ExamTimerWidget renders formatted time and circular progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExamTimerWidget(
              remainingSeconds: 85, // 01:25
              totalSeconds: 300,
            ),
          ),
        ),
      );

      expect(find.text('01:25'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('QuestionPaletteWidget displays question buttons and triggers selection', (tester) async {
      int selectedIndex = -1;
      const questions = [
        QuizQuestionEntity(id: 'q1', quizId: 'quiz1', prompt: 'Q1', type: QuestionType.singleChoice),
        QuizQuestionEntity(id: 'q2', quizId: 'quiz1', prompt: 'Q2', type: QuestionType.singleChoice),
        QuizQuestionEntity(id: 'q3', quizId: 'quiz1', prompt: 'Q3', type: QuestionType.singleChoice),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionPaletteWidget(
              questions: questions,
              currentIndex: 0,
              answers: const {'q1': 1},
              flaggedIds: const {'q2'},
              onSelectQuestion: (idx) => selectedIndex = idx,
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1 of 3 answered'), findsOneWidget);

      await tester.tap(find.text('2'));
      await tester.pump();
      expect(selectedIndex, equals(1));
    });

    testWidgets('QuestionViewCard renders options and handles choice tap', (tester) async {
      dynamic selectedAnswer;
      bool flagged = false;

      const testQ = QuizQuestionEntity(
        id: 'q_render',
        quizId: 'quiz1',
        prompt: 'Which data structure follows LIFO principle?',
        type: QuestionType.singleChoice,
        options: ['Queue', 'Stack', 'Tree'],
        correctAnswer: 1,
        points: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionViewCard(
              question: testQ,
              questionNumber: 1,
              totalQuestions: 5,
              currentAnswer: null,
              isFlagged: false,
              onAnswerChanged: (ans) => selectedAnswer = ans,
              onToggleFlag: () => flagged = true,
            ),
          ),
        ),
      );

      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.text('Which data structure follows LIFO principle?'), findsOneWidget);
      expect(find.text('Stack'), findsOneWidget);

      await tester.tap(find.text('Stack'));
      await tester.pump();
      expect(selectedAnswer, equals(1));

      await tester.tap(find.byIcon(Icons.outlined_flag));
      await tester.pump();
      expect(flagged, isTrue);
    });

    testWidgets('QuizResultCard renders score gauge, pass badge, and question breakdown', (tester) async {
      bool returned = false;

      final testQuiz = QuizEntity(
        id: 'q_res_1',
        courseId: 'c1',
        courseCode: 'CS101',
        courseTitle: 'Introduction to CS',
        title: 'Final Test',
        description: 'Done',
        timeLimitMinutes: 10,
        totalPoints: 20,
        passingPercentage: 70.0,
        availableFrom: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        questionsCount: 1,
      );

      final attempt = QuizAttemptEntity(
        id: 'att_res_1',
        quizId: 'q_res_1',
        studentId: 's1',
        studentName: 'Bob',
        startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        submittedAt: DateTime.now(),
        answers: const {'q1': 0},
        score: 20,
        totalPossiblePoints: 20,
        percentage: 100.0,
        passed: true,
      );

      const question = QuizQuestionEntity(
        id: 'q1',
        quizId: 'q_res_1',
        prompt: 'Is testing essential?',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctAnswer: true,
        points: 20,
        explanation: 'Testing ensures software quality and stability.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuizResultCard(
                quiz: testQuiz,
                attempt: attempt,
                questions: const [question],
                onReturn: () => returned = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
      expect(find.text('PASSED'), findsOneWidget);
      expect(find.text('Score'), findsOneWidget);
      expect(find.text('Back to Quizzes'), findsOneWidget);

      await tester.tap(find.text('Back to Quizzes'));
      await tester.pump();
      expect(returned, isTrue);
    });
  });
}
