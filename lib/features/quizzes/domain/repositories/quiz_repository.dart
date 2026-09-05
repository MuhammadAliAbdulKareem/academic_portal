import '../entities/quiz_entity.dart';

abstract class QuizRepository {
  Future<List<QuizEntity>> getCourseQuizzes(String courseId);

  Future<List<QuizEntity>> getAllQuizzes({String? courseId, String? studentId});

  Future<QuizEntity> getQuizById(String quizId);

  Future<List<QuizQuestionEntity>> getQuizQuestions(String quizId);

  Future<QuizEntity> createQuiz({
    required QuizEntity quiz,
    required List<QuizQuestionEntity> questions,
  });

  Future<QuizEntity> updateQuiz(QuizEntity quiz);

  Future<void> deleteQuiz(String quizId);

  Future<QuizAttemptEntity> startQuizAttempt({
    required String quizId,
    required String studentId,
    required String studentName,
    String? studentAvatar,
  });

  Future<QuizAttemptEntity> submitQuizAttempt({
    required String attemptId,
    required Map<String, dynamic> answers,
  });

  Future<List<QuizAttemptEntity>> getStudentQuizAttempts({
    required String quizId,
    required String studentId,
  });

  Future<List<QuizAttemptEntity>> getQuizRosterAttempts(String quizId);

  Future<QuizSummaryStatsEntity> getQuizStats(String quizId);
}
