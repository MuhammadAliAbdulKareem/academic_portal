import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_detail_state.dart';

class QuizDetailCubit extends Cubit<QuizDetailState> {
  final QuizRepository repository;

  QuizDetailCubit({required this.repository}) : super(const QuizDetailInitial());

  Future<void> loadQuizDetail(String quizId, {String? studentId}) async {
    emit(const QuizDetailLoading());
    try {
      final quiz = await repository.getQuizById(quizId);
      final attempts = studentId != null
          ? await repository.getStudentQuizAttempts(quizId: quizId, studentId: studentId)
          : <QuizAttemptEntity>[];

      final remaining = (quiz.maxAttempts - attempts.length).clamp(0, quiz.maxAttempts);

      emit(QuizDetailLoaded(
        quiz: quiz,
        studentAttempts: attempts,
        attemptsRemaining: remaining,
      ));
    } catch (e) {
      emit(QuizDetailError(e.toString()));
    }
  }

  Future<void> refresh(String quizId, {String? studentId}) async {
    await loadQuizDetail(quizId, studentId: studentId);
  }
}
