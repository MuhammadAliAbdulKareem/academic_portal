import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_entity.dart';

abstract class QuizExamSessionState extends Equatable {
  const QuizExamSessionState();

  @override
  List<Object?> get props => [];
}

class QuizExamSessionInitial extends QuizExamSessionState {
  const QuizExamSessionInitial();
}

class QuizExamSessionStarting extends QuizExamSessionState {
  const QuizExamSessionStarting();
}

class QuizExamSessionActive extends QuizExamSessionState {
  final QuizEntity quiz;
  final QuizAttemptEntity attempt;
  final List<QuizQuestionEntity> questions;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final Set<String> flaggedQuestionIds;
  final int remainingSeconds;
  final int totalSeconds;

  const QuizExamSessionActive({
    required this.quiz,
    required this.attempt,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.flaggedQuestionIds = const {},
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  QuizQuestionEntity get currentQuestion => questions[currentQuestionIndex];
  int get totalQuestions => questions.length;
  int get answeredCount => answers.length;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  double get progressPercentage =>
      totalQuestions == 0 ? 0.0 : (answeredCount / totalQuestions);

  String get timeRemainingFormatted {
    if (totalSeconds <= 0) return 'Untimed';
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool isQuestionAnswered(String questionId) => answers.containsKey(questionId);
  bool isQuestionFlagged(String questionId) => flaggedQuestionIds.contains(questionId);

  QuizExamSessionActive copyWith({
    QuizEntity? quiz,
    QuizAttemptEntity? attempt,
    List<QuizQuestionEntity>? questions,
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    Set<String>? flaggedQuestionIds,
    int? remainingSeconds,
    int? totalSeconds,
  }) {
    return QuizExamSessionActive(
      quiz: quiz ?? this.quiz,
      attempt: attempt ?? this.attempt,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      flaggedQuestionIds: flaggedQuestionIds ?? this.flaggedQuestionIds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }

  @override
  List<Object?> get props => [
        quiz,
        attempt,
        questions,
        currentQuestionIndex,
        answers,
        flaggedQuestionIds,
        remainingSeconds,
        totalSeconds,
      ];
}

class QuizExamSessionSubmitting extends QuizExamSessionState {
  final String attemptId;

  const QuizExamSessionSubmitting({required this.attemptId});

  @override
  List<Object?> get props => [attemptId];
}

class QuizExamSessionSubmitted extends QuizExamSessionState {
  final QuizAttemptEntity attempt;
  final QuizEntity quiz;
  final List<QuizQuestionEntity> questions;

  const QuizExamSessionSubmitted({
    required this.attempt,
    required this.quiz,
    required this.questions,
  });

  @override
  List<Object?> get props => [attempt, quiz, questions];
}

class QuizExamSessionError extends QuizExamSessionState {
  final String message;

  const QuizExamSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
