import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academic_portal/features/auth/domain/entities/user_entity.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_state.dart';
import 'package:academic_portal/features/assignments/data/datasources/assignment_remote_data_source.dart';
import 'package:academic_portal/features/assignments/data/models/assignment_model.dart';
import 'package:academic_portal/features/assignments/data/models/submission_model.dart';
import 'package:academic_portal/features/assignments/data/repositories/assignment_repository_impl.dart';
import 'package:academic_portal/features/assignments/domain/entities/assignment_entity.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/assignment_list_cubit.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/assignment_list_state.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/gradebook_cubit.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/gradebook_state.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/grading_cubit.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/grading_state.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/submission_cubit.dart';
import 'package:academic_portal/features/assignments/presentation/cubit/submission_state.dart';
import 'package:academic_portal/features/assignments/presentation/widgets/assignment_card.dart';
import 'package:academic_portal/features/assignments/presentation/widgets/grade_summary_card.dart';
import 'package:academic_portal/features/assignments/presentation/widgets/rubric_scoring_widget.dart';
import 'package:academic_portal/features/assignments/presentation/widgets/submission_item_card.dart';

class FakeStudentAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeStudentAuthCubit()
      : super(
          Authenticated(
            UserEntity(
              id: 'demo-student-01',
              email: 'student@academic.edu',
              displayName: 'Alex Mercer',
              role: UserRole.student,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Assignments & Grading Unit Tests', () {
    test('AssignmentModel & RubricItemModel serialize and deserialize correctly', () {
      const rubric = AssignmentRubricItemModel(
        id: 'rub-01',
        title: 'Correctness',
        description: 'Meets specifications',
        maxPoints: 50.0,
        levels: [
          RubricLevelModel(
            id: 'lvl-01',
            title: 'Exemplary',
            points: 50.0,
            description: 'All tests pass',
          ),
        ],
      );

      final dueDate = DateTime(2026, 9, 15, 23, 59);
      final model = AssignmentModel(
        id: 'asg-test-01',
        courseId: 'course-cs101',
        courseCode: 'CS101',
        courseTitle: 'Data Structures',
        instructorId: 'inst-01',
        instructorName: 'Dr. Vance',
        title: 'Binary Search Trees',
        description: 'Implement a BST in Dart',
        dueDate: dueDate,
        totalPoints: 100.0,
        weightPercentage: 15.0,
        submissionType: 'both',
        allowedFileExtensions: const ['zip', 'dart'],
        attachments: const ['spec.pdf'],
        rubric: const [rubric],
        isPublished: true,
      );

      final json = model.toJson();
      final fromJson = AssignmentModel.fromJson(json);

      expect(fromJson.id, equals('asg-test-01'));
      expect(fromJson.courseCode, equals('CS101'));
      expect(fromJson.title, equals('Binary Search Trees'));
      expect(fromJson.totalPoints, equals(100.0));
      expect(fromJson.rubric.length, equals(1));
      expect(fromJson.rubric.first.levels.first.title, equals('Exemplary'));

      final entity = model.toEntity();
      expect(entity.id, equals(model.id));
      expect(entity.submissionType, equals(SubmissionType.both));
    });

    test('SubmissionModel & RubricScoreModel serialize and deserialize correctly', () {
      final submittedAt = DateTime(2026, 9, 10, 14, 30);
      const score = RubricScoreModel(
        criterionId: 'rub-01',
        criterionTitle: 'Correctness',
        awardedPoints: 48.0,
        maxPoints: 50.0,
        selectedLevelTitle: 'Exemplary',
        comments: 'Great work',
      );

      final subModel = SubmissionModel(
        id: 'sub-test-01',
        assignmentId: 'asg-test-01',
        assignmentTitle: 'Binary Search Trees',
        courseCode: 'CS101',
        studentId: 'student-01',
        studentName: 'Alex Mercer',
        studentEmail: 'student@academic.edu',
        submittedAt: submittedAt,
        fileName: 'solution.zip',
        fileSizeBytes: 2048,
        textResponse: 'Here is my solution.',
        status: 'graded',
        score: 96.0,
        maxScore: 100.0,
        feedbackNotes: 'Excellent work!',
        gradedBy: 'Dr. Vance',
        rubricScores: const [score],
      );

      final json = subModel.toJson();
      final fromJson = SubmissionModel.fromJson(json);

      expect(fromJson.id, equals('sub-test-01'));
      expect(fromJson.score, equals(96.0));
      expect(fromJson.feedbackNotes, equals('Excellent work!'));
      expect(fromJson.rubricScores.first.awardedPoints, equals(48.0));

      final entity = subModel.toEntity();
      expect(entity.isGraded, isTrue);
      expect(entity.scorePercentage, equals(96.0));
      expect(entity.letterGrade, equals('A'));
      expect(entity.formattedFileSize, equals('2.0 KB'));
    });

    test('CourseGradebook calculations compute class average and extrema correctly', () {
      final assignments = [
        AssignmentEntity(
          id: 'a1',
          courseId: 'c1',
          courseCode: 'CS101',
          courseTitle: 'Data Structures',
          instructorId: 'i1',
          instructorName: 'Dr. Vance',
          title: 'A1',
          description: 'Desc',
          dueDate: DateTime(2026, 9, 1),
          totalPoints: 100.0,
        ),
      ];

      final entries = [
        const GradebookEntry(
          studentId: 's1',
          studentName: 'Alex',
          studentEmail: 'alex@edu',
          assignmentScores: {'a1': 95.0},
          totalPointsEarned: 95.0,
          totalPointsPossible: 100.0,
          percentage: 95.0,
          letterGrade: 'A',
        ),
        const GradebookEntry(
          studentId: 's2',
          studentName: 'Jordan',
          studentEmail: 'jordan@edu',
          assignmentScores: {'a1': 85.0},
          totalPointsEarned: 85.0,
          totalPointsPossible: 100.0,
          percentage: 85.0,
          letterGrade: 'B+',
        ),
      ];

      final gb = CourseGradebook(
        courseId: 'c1',
        courseCode: 'CS101',
        courseTitle: 'Data Structures',
        assignments: assignments,
        entries: entries,
      );

      expect(gb.classAveragePercentage, equals(90.0));
      expect(gb.highestPercentage, equals(95.0));
      expect(gb.lowestPercentage, equals(85.0));
    });

    test('AssignmentListCubit loads, searches, and filters assignments', () async {
      final repo = AssignmentRepositoryImpl(
        remoteDataSource: AssignmentRemoteDataSourceImpl(),
      );
      final cubit = AssignmentListCubit(repository: repo);

      await cubit.loadAssignmentsForStudent('demo-student-01');
      expect(cubit.state, isA<AssignmentListLoaded>());
      final loaded = cubit.state as AssignmentListLoaded;
      expect(loaded.allAssignments.isNotEmpty, isTrue);

      cubit.searchAssignments('Binary Search');
      final searchState = cubit.state as AssignmentListLoaded;
      expect(searchState.filteredAssignments.any((a) => a.title.contains('Binary Search')), isTrue);

      cubit.filterByCourse('MATH301');
      final courseState = cubit.state as AssignmentListLoaded;
      expect(courseState.filteredAssignments.every((a) => a.courseCode == 'MATH301'), isTrue);

      await cubit.close();
    });

    test('SubmissionCubit rejects empty inputs and submits valid payloads', () async {
      final repo = AssignmentRepositoryImpl(
        remoteDataSource: AssignmentRemoteDataSourceImpl(),
      );
      final cubit = SubmissionCubit(repository: repo);

      // Empty payload rejection
      await cubit.submitWork(
        assignmentId: 'asg-01',
        assignmentTitle: 'Test',
        courseCode: 'CS101',
        studentId: 's1',
        studentName: 'Student',
        studentEmail: 's@edu',
        fileName: '',
        textResponse: '',
      );
      expect(cubit.state, isA<SubmissionFailure>());

      // Valid payload submission
      await cubit.submitWork(
        assignmentId: 'asg-cs101-01',
        assignmentTitle: 'Test Assignment',
        courseCode: 'CS101',
        studentId: 'demo-student-01',
        studentName: 'Alex Mercer',
        studentEmail: 'student@academic.edu',
        fileName: 'solution.zip',
        fileSizeBytes: 1048576,
        textResponse: 'Here is my complete solution.',
      );
      expect(cubit.state, isA<SubmissionSuccess>());

      await cubit.close();
    });

    test('GradingCubit scores rubrics and publishes grade', () async {
      final repo = AssignmentRepositoryImpl(
        remoteDataSource: AssignmentRemoteDataSourceImpl(),
      );
      final cubit = GradingCubit(repository: repo);

      const rubric = [
        AssignmentRubricItem(
          id: 'r1',
          title: 'Code Quality',
          description: 'Style and testing',
          maxPoints: 50.0,
        ),
      ];

      final sub = SubmissionEntity(
        id: 'sub-cs101-jordan',
        assignmentId: 'asg-cs101-01',
        assignmentTitle: 'Balanced BST',
        courseCode: 'CS101',
        studentId: 'student-02',
        studentName: 'Jordan Lee',
        studentEmail: 'jordan@edu',
        submittedAt: DateTime.now(),
      );

      cubit.initForSubmission(sub, rubric);
      expect(cubit.state, isA<GradingLoaded>());

      cubit.updateCriterionScore('r1', 48.0, levelTitle: 'Exemplary');
      cubit.updateFeedbackNotes('Great code structure Jordan!');
      final state = cubit.state as GradingLoaded;
      expect(state.criterionScores['r1'], equals(48.0));
      expect(state.totalScore, equals(48.0));

      await cubit.publishGrade(gradedBy: 'Dr. Vance');
      expect(cubit.state, isA<GradingSuccess>());

      await cubit.close();
    });

    test('GradebookCubit loads gradebook entity', () async {
      final repo = AssignmentRepositoryImpl(
        remoteDataSource: AssignmentRemoteDataSourceImpl(),
      );
      final cubit = GradebookCubit(repository: repo);

      await cubit.loadGradebook('demo-course-01');
      expect(cubit.state, isA<GradebookLoaded>());
      final gb = (cubit.state as GradebookLoaded).gradebook;
      expect(gb.entries.isNotEmpty, isTrue);

      await cubit.close();
    });
  });

  group('Assignments & Grading Widget Tests', () {
    testWidgets('AssignmentCard renders title, course code, and submit action',
        (tester) async {
      final assignment = AssignmentEntity(
        id: 'asg-widget-01',
        courseId: 'demo-course-01',
        courseCode: 'CS101',
        courseTitle: 'Data Structures',
        instructorId: 'inst-01',
        instructorName: 'Dr. Robert Vance',
        title: 'Binary Search Tree Implementation',
        description: 'Implement a self-balancing red-black tree with rotational proofs.',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        totalPoints: 100.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssignmentCard(
              assignment: assignment,
              isInstructor: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('CS101'), findsOneWidget);
      expect(find.text('Binary Search Tree Implementation'), findsOneWidget);
      expect(find.text('Submit Work'), findsOneWidget);
      expect(find.text('100 pts'), findsOneWidget);
    });

    testWidgets('SubmissionItemCard renders student name, avatar, and grade button',
        (tester) async {
      final sub = SubmissionEntity(
        id: 'sub-test',
        assignmentId: 'asg-01',
        assignmentTitle: 'Project 1',
        courseCode: 'CS101',
        studentId: 'st-02',
        studentName: 'Jordan Lee',
        studentEmail: 'jordan.lee@academic.edu',
        submittedAt: DateTime(2026, 9, 10, 11, 0),
        fileName: 'jordan_solution.zip',
        fileSizeBytes: 2097152,
        status: SubmissionStatus.submitted,
      );

      bool gradePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubmissionItemCard(
              submission: sub,
              onGrade: () => gradePressed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Jordan Lee'), findsOneWidget);
      expect(find.text('jordan.lee@academic.edu'), findsOneWidget);
      expect(find.text('Grade Submission'), findsOneWidget);
      expect(find.text('Needs Grading'), findsOneWidget);

      await tester.tap(find.text('Grade Submission'));
      await tester.pump();
      expect(gradePressed, isTrue);
    });

    testWidgets('RubricScoringWidget renders criteria and calculates points',
        (tester) async {
      const rubric = [
        AssignmentRubricItem(
          id: 'r-01',
          title: 'Algorithmic Efficiency',
          description: 'Runtime meets asymptotic bounds',
          maxPoints: 50.0,
          levels: [
            RubricLevel(
              id: 'l1',
              title: 'Exemplary',
              points: 50.0,
              description: 'O(log n) verified',
            ),
            RubricLevel(
              id: 'l2',
              title: 'Proficient',
              points: 40.0,
              description: 'O(n) in worst case',
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RubricScoringWidget(
                rubric: rubric,
                awardedScores: const {'r-01': 50.0},
                selectedLevels: const {'r-01': 'Exemplary'},
                isReadOnly: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Algorithmic Efficiency'), findsOneWidget);
      expect(find.text('Exemplary'), findsOneWidget);
      expect(find.text('50.0 / 50.0 pts'), findsOneWidget);
    });

    testWidgets('GradeSummaryCard renders grade letter and feedback',
        (tester) async {
      final sub = SubmissionEntity(
        id: 'sub-graded',
        assignmentId: 'asg-01',
        assignmentTitle: 'Project 1',
        courseCode: 'CS101',
        studentId: 'st-01',
        studentName: 'Alex Mercer',
        studentEmail: 'student@academic.edu',
        submittedAt: DateTime(2026, 9, 1),
        status: SubmissionStatus.graded,
        score: 95.0,
        maxScore: 100.0,
        feedbackNotes: 'Superb implementation Alex!',
        gradedBy: 'Dr. Robert Vance',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GradeSummaryCard(submission: sub),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Grade A'), findsOneWidget);
      expect(find.text('95.0 / 100.0 pts (95.0%)'), findsOneWidget);
      expect(find.text('Superb implementation Alex!'), findsOneWidget);
      expect(find.text('Graded by Dr. Robert Vance'), findsOneWidget);
    });
  });
}
