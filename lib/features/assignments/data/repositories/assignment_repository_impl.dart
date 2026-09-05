import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../datasources/assignment_remote_data_source.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentRemoteDataSource remoteDataSource;

  AssignmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AssignmentEntity>> getAssignmentsForCourse(String courseId) async {
    final models = await remoteDataSource.getAssignmentsForCourse(courseId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<AssignmentEntity>> getAssignmentsForStudent(String studentId) async {
    final models = await remoteDataSource.getAssignmentsForStudent(studentId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AssignmentEntity> getAssignmentById(String assignmentId) async {
    final model = await remoteDataSource.getAssignmentById(assignmentId);
    return model.toEntity();
  }

  @override
  Future<AssignmentEntity> createAssignment(AssignmentEntity assignment) async {
    final model = AssignmentModel.fromEntity(assignment);
    final saved = await remoteDataSource.createAssignment(model);
    return saved.toEntity();
  }

  @override
  Future<SubmissionEntity> submitAssignment(SubmissionEntity submission) async {
    final model = SubmissionModel.fromEntity(submission);
    final saved = await remoteDataSource.submitAssignment(model);
    return saved.toEntity();
  }

  @override
  Future<List<SubmissionEntity>> getSubmissionsForAssignment(String assignmentId) async {
    final models = await remoteDataSource.getSubmissionsForAssignment(assignmentId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SubmissionEntity?> getStudentSubmission({
    required String assignmentId,
    required String studentId,
  }) async {
    final model = await remoteDataSource.getStudentSubmission(assignmentId, studentId);
    return model?.toEntity();
  }

  @override
  Future<SubmissionEntity> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
    required List<RubricScore> rubricScores,
    required String gradedBy,
  }) async {
    final rubricModels = rubricScores.map((r) => RubricScoreModel.fromEntity(r)).toList();
    final updated = await remoteDataSource.gradeSubmission(
      submissionId: submissionId,
      score: score,
      feedback: feedback,
      rubricScores: rubricModels,
      gradedBy: gradedBy,
    );
    return updated.toEntity();
  }

  @override
  Future<CourseGradebook> getCourseGradebook(String courseId) async {
    final assignments = await getAssignmentsForCourse(courseId);
    final allSubmissions = await remoteDataSource.getAllSubmissionsForCourse(courseId);

    // Mock enrolled roster
    final students = [
      {
        'id': 'demo-student-01',
        'name': 'Alex Mercer',
        'email': 'student@academic.edu',
        'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      },
      {
        'id': 'student-02',
        'name': 'Jordan Lee',
        'email': 'jordan.lee@academic.edu',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      },
      {
        'id': 'student-03',
        'name': 'Sarah Chen',
        'email': 'sarah.chen@academic.edu',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      },
      {
        'id': 'student-04',
        'name': 'Marcus Wright',
        'email': 'marcus.w@academic.edu',
        'avatar': null,
      },
    ];

    final entries = <GradebookEntry>[];
    final totalPossible = assignments.fold<double>(0.0, (acc, a) => acc + a.totalPoints);

    for (final st in students) {
      final sId = st['id'] as String;
      final scoreMap = <String, double?>{};
      double earned = 0.0;

      for (final asg in assignments) {
        final sub = allSubmissions
            .where((s) => s.assignmentId == asg.id && s.studentId == sId)
            .firstOrNull;

        if (sub != null && sub.score != null) {
          scoreMap[asg.id] = sub.score;
          earned += sub.score!;
        } else {
          scoreMap[asg.id] = null;
        }
      }

      final percentage = totalPossible > 0 ? (earned / totalPossible) * 100.0 : 0.0;

      String letter;
      if (percentage >= 93) {
        letter = 'A';
      } else if (percentage >= 90) {
        letter = 'A-';
      } else if (percentage >= 85) {
        letter = 'B+';
      } else if (percentage >= 80) {
        letter = 'B';
      } else if (percentage >= 75) {
        letter = 'C+';
      } else if (percentage >= 70) {
        letter = 'C';
      } else if (percentage >= 60) {
        letter = 'D';
      } else {
        letter = 'F';
      }

      entries.add(
        GradebookEntry(
          studentId: sId,
          studentName: st['name'] as String,
          studentEmail: st['email'] as String,
          studentAvatar: st['avatar'],
          assignmentScores: scoreMap,
          totalPointsEarned: earned,
          totalPointsPossible: totalPossible,
          percentage: percentage,
          letterGrade: letter,
        ),
      );
    }

    return CourseGradebook(
      courseId: courseId,
      courseCode: assignments.isNotEmpty ? assignments.first.courseCode : 'COURSE',
      courseTitle: assignments.isNotEmpty ? assignments.first.courseTitle : 'Course Title',
      assignments: assignments,
      entries: entries,
    );
  }
}
