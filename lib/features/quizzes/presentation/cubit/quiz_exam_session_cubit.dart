import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_exam_session_state.dart';

class QuizExamSessionCubit extends Cubit<QuizExamSessionState> {
  final QuizRepository repository;
  Timer? _timer;

  QuizExamSessionCubit({required this.repository})
      : super(const QuizExamSessionInitial());

  Future<void> startSession({
    required String quizId,
    required String studentId,
    required String studentName,
    String? studentAvatar,
  }) async {
    emit(const QuizExamSessionStarting());
    try {
      final quiz = await repository.getQuizById(quizId);
      final attempt = await repository.startQuizAttempt(
        quizId: quizId,
        studentId: studentId,
        studentName: studentName,
        studentAvatar: studentAvatar,
      );
      var questions = await repository.getQuizQuestions(quizId);
      if (quiz.shuffleQuestions) {
        questions = List<QuizQuestionEntity>.from(questions)..shuffle();
      }

      final totalSeconds = quiz.timeLimitMinutes > 0 ? quiz.timeLimitMinutes * 60 : 0;

      emit(QuizExamSessionActive(
        quiz: quiz,
        attempt: attempt,
        questions: questions,
        remainingSeconds: totalSeconds,
        totalSeconds: totalSeconds,
      ));

      _startTimer();
    } catch (e) {
      emit(QuizExamSessionError(e.toString()));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (state is! QuizExamSessionActive) return;
    final current = state as QuizExamSessionActive;
    if (current.totalSeconds <= 0) return; // Untimed quiz

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is! QuizExamSessionActive) {
        timer.cancel();
        return;
      }
      final active = state as QuizExamSessionActive;
      final nextSeconds = active.remainingSeconds - 1;

      if (nextSeconds <= 0) {
        timer.cancel();
        submitExam();
      } else {
        emit(active.copyWith(remainingSeconds: nextSeconds));
      }
    });
  }

  void selectAnswer(String questionId, dynamic answer) {
    if (state is! QuizExamSessionActive) return;
    final active = state as QuizExamSessionActive;
    final newAnswers = Map<String, dynamic>.from(active.answers);
    newAnswers[questionId] = answer;
    emit(active.copyWith(answers: newAnswers));
  }

  void toggleFlagQuestion(String questionId) {
    if (state is! QuizExamSessionActive) return;
    final active = state as QuizExamSessionActive;
    final newFlags = Set<String>.from(active.flaggedQuestionIds);
    if (newFlags.contains(questionId)) {
      newFlags.remove(questionId);
    } else {
      newFlags.add(questionId);
    }
    emit(active.copyWith(flaggedQuestionIds: newFlags));
  }

  void nextQuestion() {
    if (state is! QuizExamSessionActive) return;
    final active = state as QuizExamSessionActive;
    if (active.currentQuestionIndex < active.questions.length - 1) {
      emit(active.copyWith(currentQuestionIndex: active.currentQuestionIndex + 1));
    }
  }

  void previousQuestion() {
    if (state is! QuizExamSessionActive) return;
    final active = state as QuizExamSessionActive;
    if (active.currentQuestionIndex > 0) {
      emit(active.copyWith(currentQuestionIndex: active.currentQuestionIndex - 1));
    }
  }

  void jumpToQuestion(int index) {
    if (state is! QuizExamSessionActive) return;
    final active = state as QuizExamSessionActive;
    if (index >= 0 && index < active.questions.length) {
      emit(active.copyWith(currentQuestionIndex: index));
    }
  }

  Future<void> submitExam() async {
    if (state is! QuizExamSessionActive) return;
    final active = state as QuizExamSessionActive;
    _timer?.cancel();

    emit(QuizExamSessionSubmitting(attemptId: active.attempt.id));

    try {
      final completedAttempt = await repository.submitQuizAttempt(
        attemptId: active.attempt.id,
        answers: active.answers,
      );
      emit(QuizExamSessionSubmitted(
        attempt: completedAttempt,
        quiz: active.quiz,
        questions: active.questions,
      ));
    } catch (e) {
      emit(QuizExamSessionError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
