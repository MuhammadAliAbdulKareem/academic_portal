import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';

abstract class AssignmentRemoteDataSource {
  Future<List<AssignmentModel>> getAssignmentsForCourse(String courseId);
  Future<List<AssignmentModel>> getAssignmentsForStudent(String studentId);
  Future<AssignmentModel> getAssignmentById(String assignmentId);
  Future<AssignmentModel> createAssignment(AssignmentModel assignment);
  Future<SubmissionModel> submitAssignment(SubmissionModel submission);
  Future<List<SubmissionModel>> getSubmissionsForAssignment(String assignmentId);
  Future<SubmissionModel?> getStudentSubmission(String assignmentId, String studentId);
  Future<SubmissionModel> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
    required List<RubricScoreModel> rubricScores,
    required String gradedBy,
  });
  Future<List<SubmissionModel>> getAllSubmissionsForCourse(String courseId);
}

class AssignmentRemoteDataSourceImpl implements AssignmentRemoteDataSource {
  final FirebaseFirestore? firestore;

  AssignmentRemoteDataSourceImpl({this.firestore});

  // Comprehensive in-memory mock datasets
  static final List<AssignmentModel> _mockAssignments = [
    AssignmentModel(
      id: 'asg-cs101-01',
      courseId: 'demo-course-01',
      courseCode: 'CS101',
      courseTitle: 'Data Structures & Algorithms',
      instructorId: 'demo-instructor-01',
      instructorName: 'Dr. Robert Vance',
      title: 'Problem Set 1: Balanced Binary Search Trees',
      description:
          'Implement a self-balancing Red-Black Tree in Dart or C++. Include insertion, deletion, and rotation routines with O(log n) rebalancing proofs. Submit your source files along with benchmark runtime plots demonstrating performance characteristics over 100,000 randomized elements.',
      dueDate: DateTime.now().add(const Duration(days: 3, hours: 4)),
      totalPoints: 100.0,
      weightPercentage: 15.0,
      submissionType: 'both',
      allowedFileExtensions: ['zip', 'dart', 'pdf', 'tar.gz'],
      attachments: ['spec_rbtree_v2.pdf', 'benchmark_starter.dart'],
      isPublished: true,
      rubric: const [
        AssignmentRubricItemModel(
          id: 'rub-01',
          title: 'Algorithmic Correctness & Rotations',
          description:
              'Implements left/right tree rotations and recoloring preserving red-black invariant rules without leaks.',
          maxPoints: 40.0,
          levels: [
            RubricLevelModel(
              id: 'lvl-01a',
              title: 'Exemplary',
              points: 40.0,
              description: 'Passes all edge tests including duplicate keys and sequential insertions.',
            ),
            RubricLevelModel(
              id: 'lvl-01b',
              title: 'Proficient',
              points: 32.0,
              description: 'Basic rotations correct; minor issues with root recoloring in edge cases.',
            ),
            RubricLevelModel(
              id: 'lvl-01c',
              title: 'Developing',
              points: 20.0,
              description: 'Rotations break tree invariants under heavy stress testing.',
            ),
          ],
        ),
        AssignmentRubricItemModel(
          id: 'rub-02',
          title: 'Clean Architecture & Code Quality',
          description: 'Code is well-structured, modular, memory-efficient, and cleanly formatted.',
          maxPoints: 30.0,
          levels: [
            RubricLevelModel(
              id: 'lvl-02a',
              title: 'Exemplary',
              points: 30.0,
              description: 'Exemplary style, meaningful variable nomenclature, zero linter warnings.',
            ),
            RubricLevelModel(
              id: 'lvl-02b',
              title: 'Satisfactory',
              points: 24.0,
              description: 'Clean code with minor redundancy or lacking inline documentation.',
            ),
          ],
        ),
        AssignmentRubricItemModel(
          id: 'rub-03',
          title: 'Benchmarking & Experimental Analysis',
          description: 'Empirical runtime analysis matches asymptotic Big-O theoretical limits.',
          maxPoints: 30.0,
          levels: [
            RubricLevelModel(
              id: 'lvl-03a',
              title: 'Exemplary',
              points: 30.0,
              description: 'High quality log-scale plots with detailed deviation analysis.',
            ),
            RubricLevelModel(
              id: 'lvl-03b',
              title: 'Adequate',
              points: 22.0,
              description: 'Plots provided but lacking comparative analysis against std::map.',
            ),
          ],
        ),
      ],
    ),
    AssignmentModel(
      id: 'asg-cs101-02',
      courseId: 'demo-course-01',
      courseCode: 'CS101',
      courseTitle: 'Data Structures & Algorithms',
      instructorId: 'demo-instructor-01',
      instructorName: 'Dr. Robert Vance',
      title: 'Problem Set 2: Graph Theory & Shortest Paths',
      description:
          'Implement Dijkstra and A* pathfinding on weighted graphs. Provide benchmark comparisons on road network datasets.',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      totalPoints: 100.0,
      weightPercentage: 15.0,
      submissionType: 'fileUpload',
      allowedFileExtensions: ['zip', 'pdf'],
      attachments: ['city_road_nodes.json'],
      isPublished: true,
      rubric: const [
        AssignmentRubricItemModel(
          id: 'rub-g1',
          title: 'Dijkstra Implementation',
          description: 'Correct priority queue heap implementation.',
          maxPoints: 50.0,
        ),
        AssignmentRubricItemModel(
          id: 'rub-g2',
          title: 'A* Heuristic Optimality',
          description: 'Admissible and consistent heuristic design.',
          maxPoints: 50.0,
        ),
      ],
    ),
    AssignmentModel(
      id: 'asg-cs201-01',
      courseId: 'demo-course-02',
      courseCode: 'CS201',
      courseTitle: 'Web Application Architectures',
      instructorId: 'demo-instructor-01',
      instructorName: 'Dr. Robert Vance',
      title: 'Project 1: Secure OAuth2 PKCE Authentication Gateway',
      description:
          'Build a resilient OpenID Connect identity provider client supporting authorization code grant with PKCE, JWT token rotation, and refresh token revocation.',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      totalPoints: 100.0,
      weightPercentage: 20.0,
      submissionType: 'both',
      allowedFileExtensions: ['zip', 'tar.gz', 'pdf'],
      attachments: ['oauth_security_guidelines.pdf'],
      isPublished: true,
      rubric: const [
        AssignmentRubricItemModel(
          id: 'rub-oa1',
          title: 'Security & PKCE Verification',
          description: 'S256 code challenge generation and state verification.',
          maxPoints: 40.0,
        ),
        AssignmentRubricItemModel(
          id: 'rub-oa2',
          title: 'Token Lifecycle Management',
          description: 'Silent token refresh and cryptographic signature validation.',
          maxPoints: 30.0,
        ),
        AssignmentRubricItemModel(
          id: 'rub-oa3',
          title: 'Integration Test Suite',
          description: 'End-to-end integration tests simulating token expiration.',
          maxPoints: 30.0,
        ),
      ],
    ),
    AssignmentModel(
      id: 'asg-math301-01',
      courseId: 'demo-course-03',
      courseCode: 'MATH301',
      courseTitle: 'Advanced Linear Algebra',
      instructorId: 'demo-instructor-02',
      instructorName: 'Prof. Marcus Brody',
      title: 'Problem Set: Spectral Theorem & SVD Decompositions',
      description:
          'Written mathematical proofs solving eigenvalues, orthogonal projections, and Singular Value Decomposition applied to image compression.',
      dueDate: DateTime.now().add(const Duration(days: 5, hours: 12)),
      totalPoints: 50.0,
      weightPercentage: 10.0,
      submissionType: 'fileUpload',
      allowedFileExtensions: ['pdf'],
      attachments: ['math301_pset3.pdf'],
      isPublished: true,
      rubric: const [
        AssignmentRubricItemModel(
          id: 'rub-m1',
          title: 'Proof Rigor & Formalism',
          description: 'Correctness of mathematical derivations.',
          maxPoints: 30.0,
        ),
        AssignmentRubricItemModel(
          id: 'rub-m2',
          title: 'SVD Computational Application',
          description: 'Python or MATLAB compression ratio analysis.',
          maxPoints: 20.0,
        ),
      ],
    ),
  ];

  static final List<SubmissionModel> _mockSubmissions = [
    // Graded submission for Alex Mercer in CS201
    SubmissionModel(
      id: 'sub-cs201-alex',
      assignmentId: 'asg-cs201-01',
      assignmentTitle: 'Project 1: Secure OAuth2 PKCE Authentication Gateway',
      courseCode: 'CS201',
      studentId: 'demo-student-01',
      studentName: 'Alex Mercer',
      studentEmail: 'student@academic.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      fileName: 'alex_mercer_oauth2_pkce.zip',
      fileSizeBytes: 2457600, // 2.3 MB
      textResponse:
          'Implemented OAuth2 PKCE using Dart crypto package with S256 code challenge. Automated refresh token rotation is covered with 18 unit and integration tests.',
      status: 'graded',
      score: 94.0,
      maxScore: 100.0,
      feedbackNotes:
          'Outstanding engineering design, Alex! The PKCE handshake and secure cookie storage adhere to the latest RFC guidelines. Minor recommendation: consider adding rate limiting on the token refresh endpoint to safeguard against brute-force attacks.',
      gradedAt: DateTime.now().subtract(const Duration(days: 1)),
      gradedBy: 'Dr. Robert Vance',
      rubricScores: const [
        RubricScoreModel(
          criterionId: 'rub-oa1',
          criterionTitle: 'Security & PKCE Verification',
          awardedPoints: 38.0,
          maxPoints: 40.0,
          selectedLevelTitle: 'Exemplary',
          comments: 'Flawless PKCE implementation.',
        ),
        RubricScoreModel(
          criterionId: 'rub-oa2',
          criterionTitle: 'Token Lifecycle Management',
          awardedPoints: 29.0,
          maxPoints: 30.0,
          selectedLevelTitle: 'Exemplary',
          comments: 'Clean token refresh rotation logic.',
        ),
        RubricScoreModel(
          criterionId: 'rub-oa3',
          criterionTitle: 'Integration Test Suite',
          awardedPoints: 27.0,
          maxPoints: 30.0,
          selectedLevelTitle: 'Proficient',
          comments: 'Great test coverage; add timeout edge case simulation.',
        ),
      ],
    ),
    // Other students' submissions for CS101 assignment (for instructor grading queue)
    SubmissionModel(
      id: 'sub-cs101-jordan',
      assignmentId: 'asg-cs101-01',
      assignmentTitle: 'Problem Set 1: Balanced Binary Search Trees',
      courseCode: 'CS101',
      studentId: 'student-02',
      studentName: 'Jordan Lee',
      studentEmail: 'jordan.lee@academic.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      submittedAt: DateTime.now().subtract(const Duration(hours: 14)),
      fileName: 'jordan_lee_rbtree.zip',
      fileSizeBytes: 1843200,
      textResponse: 'Completed all rotation tests and added GNU plot graphs.',
      status: 'submitted', // Needs grading
      score: null,
      maxScore: 100.0,
    ),
    SubmissionModel(
      id: 'sub-cs101-sarah',
      assignmentId: 'asg-cs101-01',
      assignmentTitle: 'Problem Set 1: Balanced Binary Search Trees',
      courseCode: 'CS101',
      studentId: 'student-03',
      studentName: 'Sarah Chen',
      studentEmail: 'sarah.chen@academic.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      fileName: 'sarah_chen_rbtree.zip',
      fileSizeBytes: 3145728,
      textResponse: 'Complete solution in C++17 with valgrind clean output.',
      status: 'graded',
      score: 98.0,
      maxScore: 100.0,
      feedbackNotes: 'Brilliant work Sarah! Code is exceptionally clean.',
      gradedAt: DateTime.now().subtract(const Duration(hours: 4)),
      gradedBy: 'Dr. Robert Vance',
      rubricScores: const [
        RubricScoreModel(
          criterionId: 'rub-01',
          criterionTitle: 'Algorithmic Correctness & Rotations',
          awardedPoints: 40.0,
          maxPoints: 40.0,
        ),
        RubricScoreModel(
          criterionId: 'rub-02',
          criterionTitle: 'Clean Architecture & Code Quality',
          awardedPoints: 29.0,
          maxPoints: 30.0,
        ),
        RubricScoreModel(
          criterionId: 'rub-03',
          criterionTitle: 'Benchmarking & Experimental Analysis',
          awardedPoints: 29.0,
          maxPoints: 30.0,
        ),
      ],
    ),
  ];

  @override
  Future<List<AssignmentModel>> getAssignmentsForCourse(String courseId) async {
    if (firestore != null) {
      try {
        final snapshot = await firestore!
            .collection('assignments')
            .where('courseId', isEqualTo: courseId)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => AssignmentModel.fromFirestore(doc)).toList();
        }
      } catch (_) {
        // Fallback to in-memory mock
      }
    }

    return _mockAssignments.where((a) => a.courseId == courseId).toList();
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsForStudent(String studentId) async {
    if (firestore != null) {
      try {
        final snapshot = await firestore!.collection('assignments').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => AssignmentModel.fromFirestore(doc)).toList();
        }
      } catch (_) {
        // Fallback
      }
    }

    return List.from(_mockAssignments);
  }

  @override
  Future<AssignmentModel> getAssignmentById(String assignmentId) async {
    if (firestore != null) {
      try {
        final doc = await firestore!.collection('assignments').doc(assignmentId).get();
        if (doc.exists) {
          return AssignmentModel.fromFirestore(doc);
        }
      } catch (_) {
        // Fallback
      }
    }

    final match = _mockAssignments.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => _mockAssignments.first,
    );
    return match;
  }

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    if (firestore != null) {
      try {
        final docRef = firestore!.collection('assignments').doc(assignment.id);
        await docRef.set(assignment.toFirestore());
      } catch (_) {
        // Fallback
      }
    }

    _mockAssignments.removeWhere((a) => a.id == assignment.id);
    _mockAssignments.insert(0, assignment);
    return assignment;
  }

  @override
  Future<SubmissionModel> submitAssignment(SubmissionModel submission) async {
    if (firestore != null) {
      try {
        final docRef = firestore!.collection('submissions').doc(submission.id);
        await docRef.set(submission.toFirestore());
      } catch (_) {
        // Fallback
      }
    }

    _mockSubmissions.removeWhere(
      (s) => s.assignmentId == submission.assignmentId && s.studentId == submission.studentId,
    );
    _mockSubmissions.insert(0, submission);
    return submission;
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsForAssignment(String assignmentId) async {
    if (firestore != null) {
      try {
        final snapshot = await firestore!
            .collection('submissions')
            .where('assignmentId', isEqualTo: assignmentId)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => SubmissionModel.fromFirestore(doc)).toList();
        }
      } catch (_) {
        // Fallback
      }
    }

    return _mockSubmissions.where((s) => s.assignmentId == assignmentId).toList();
  }

  @override
  Future<SubmissionModel?> getStudentSubmission(String assignmentId, String studentId) async {
    if (firestore != null) {
      try {
        final snapshot = await firestore!
            .collection('submissions')
            .where('assignmentId', isEqualTo: assignmentId)
            .where('studentId', isEqualTo: studentId)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return SubmissionModel.fromFirestore(snapshot.docs.first);
        }
      } catch (_) {
        // Fallback
      }
    }

    try {
      return _mockSubmissions.firstWhere(
        (s) =>
            s.assignmentId == assignmentId &&
            (s.studentId == studentId || studentId == 'demo-student-01'),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SubmissionModel> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
    required List<RubricScoreModel> rubricScores,
    required String gradedBy,
  }) async {
    if (firestore != null) {
      try {
        final docRef = firestore!.collection('submissions').doc(submissionId);
        await docRef.update({
          'score': score,
          'status': 'graded',
          'feedbackNotes': feedback,
          'gradedAt': Timestamp.now(),
          'gradedBy': gradedBy,
          'rubricScores': rubricScores.map((e) => e.toJson()).toList(),
        });
      } catch (_) {
        // Fallback
      }
    }

    final index = _mockSubmissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      final existing = _mockSubmissions[index];
      final updated = SubmissionModel(
        id: existing.id,
        assignmentId: existing.assignmentId,
        assignmentTitle: existing.assignmentTitle,
        courseCode: existing.courseCode,
        studentId: existing.studentId,
        studentName: existing.studentName,
        studentEmail: existing.studentEmail,
        studentAvatar: existing.studentAvatar,
        submittedAt: existing.submittedAt,
        fileName: existing.fileName,
        fileSizeBytes: existing.fileSizeBytes,
        textResponse: existing.textResponse,
        status: 'graded',
        score: score,
        maxScore: existing.maxScore,
        feedbackNotes: feedback,
        gradedAt: DateTime.now(),
        gradedBy: gradedBy,
        rubricScores: rubricScores,
      );
      _mockSubmissions[index] = updated;
      return updated;
    }

    throw Exception('Submission not found: $submissionId');
  }

  @override
  Future<List<SubmissionModel>> getAllSubmissionsForCourse(String courseId) async {
    final assignments = await getAssignmentsForCourse(courseId);
    final assignmentIds = assignments.map((a) => a.id).toSet();
    return _mockSubmissions.where((s) => assignmentIds.contains(s.assignmentId)).toList();
  }
}
