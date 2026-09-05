import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_data_source.dart';
import '../models/quiz_model.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  const QuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<QuizEntity>> getAllQuizzes({String? courseId, String? studentId}) async {
    try {
      return await remoteDataSource.getAllQuizzes(courseId: courseId, studentId: studentId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve quizzes: ${e.toString()}');
    }
  }

  @override
  Future<List<QuizEntity>> getCourseQuizzes(String courseId) async {
    try {
      return await remoteDataSource.getCourseQuizzes(courseId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve course quizzes: ${e.toString()}');
    }
  }

  @override
  Future<QuizEntity> getQuizById(String quizId) async {
    try {
      return await remoteDataSource.getQuizById(quizId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve quiz details: ${e.toString()}');
    }
  }

  @override
  Future<List<QuizQuestionEntity>> getQuizQuestions(String quizId) async {
    try {
      return await remoteDataSource.getQuizQuestions(quizId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve quiz questions: ${e.toString()}');
    }
  }

  @override
  Future<QuizEntity> createQuiz({
    required QuizEntity quiz,
    required List<QuizQuestionEntity> questions,
  }) async {
    try {
      final quizModel = QuizModel.fromEntity(quiz);
      final questionModels = questions.map(QuizQuestionModel.fromEntity).toList();
      return await remoteDataSource.createQuiz(quizModel, questionModels);
    } catch (e) {
      throw ServerException(message: 'Failed to create quiz: ${e.toString()}');
    }
  }

  @override
  Future<QuizEntity> updateQuiz(QuizEntity quiz) async {
    try {
      final quizModel = QuizModel.fromEntity(quiz);
      return await remoteDataSource.updateQuiz(quizModel);
    } catch (e) {
      throw ServerException(message: 'Failed to update quiz: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      await remoteDataSource.deleteQuiz(quizId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete quiz: ${e.toString()}');
    }
  }

  @override
  Future<QuizAttemptEntity> startQuizAttempt({
    required String quizId,
    required String studentId,
    required String studentName,
    String? studentAvatar,
  }) async {
    try {
      return await remoteDataSource.startQuizAttempt(
        quizId: quizId,
        studentId: studentId,
        studentName: studentName,
        studentAvatar: studentAvatar,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to start quiz attempt: ${e.toString()}');
    }
  }

  @override
  Future<QuizAttemptEntity> submitQuizAttempt({
    required String attemptId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      return await remoteDataSource.submitQuizAttempt(
        attemptId: attemptId,
        answers: answers,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to submit quiz attempt: ${e.toString()}');
    }
  }

  @override
  Future<List<QuizAttemptEntity>> getStudentQuizAttempts({
    required String quizId,
    required String studentId,
  }) async {
    try {
      return await remoteDataSource.getStudentQuizAttempts(
        quizId: quizId,
        studentId: studentId,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to get student quiz attempts: ${e.toString()}');
    }
  }

  @override
  Future<List<QuizAttemptEntity>> getQuizRosterAttempts(String quizId) async {
    try {
      return await remoteDataSource.getQuizRosterAttempts(quizId);
    } catch (e) {
      throw ServerException(message: 'Failed to retrieve quiz roster attempts: ${e.toString()}');
    }
  }

  @override
  Future<QuizSummaryStatsEntity> getQuizStats(String quizId) async {
    try {
      return await remoteDataSource.getQuizStats(quizId);
    } catch (e) {
      throw ServerException(message: 'Failed to get quiz statistics: ${e.toString()}');
    }
  }
}
