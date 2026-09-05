import '../entities/assignment_entity.dart';

/// Abstract contract for Assignment and Grading repository operations.
abstract class AssignmentRepository {
  /// Fetches all assignments created for a specific course.
  Future<List<AssignmentEntity>> getAssignmentsForCourse(String courseId);

  /// Fetches all assignments associated with a student across enrolled courses.
  Future<List<AssignmentEntity>> getAssignmentsForStudent(String studentId);

  /// Retrieves an assignment by its unique ID.
  Future<AssignmentEntity> getAssignmentById(String assignmentId);

  /// Creates a new assignment.
  Future<AssignmentEntity> createAssignment(AssignmentEntity assignment);

  /// Submits an assignment response (file and/or text).
  Future<SubmissionEntity> submitAssignment(SubmissionEntity submission);

  /// Fetches all submissions submitted for a particular assignment.
  Future<List<SubmissionEntity>> getSubmissionsForAssignment(String assignmentId);

  /// Retrieves a specific student's submission for an assignment, if any.
  Future<SubmissionEntity?> getStudentSubmission({
    required String assignmentId,
    required String studentId,
  });

  /// Evaluates and grades a student submission with score, feedback, and rubric breakdown.
  Future<SubmissionEntity> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
    required List<RubricScore> rubricScores,
    required String gradedBy,
  });

  /// Generates or fetches the comprehensive gradebook roster for a course.
  Future<CourseGradebook> getCourseGradebook(String courseId);
}
