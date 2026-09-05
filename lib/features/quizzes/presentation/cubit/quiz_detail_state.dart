import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_entity.dart';

abstract class QuizDetailState extends Equatable {
  const QuizDetailState();

  @override
  List<Object?> get props => [];
}

class QuizDetailInitial extends QuizDetailState {
  const QuizDetailInitial();
}

class QuizDetailLoading extends QuizDetailState {
  const QuizDetailLoading();
}

class QuizDetailLoaded extends QuizDetailState {
  final QuizEntity quiz;
  final List<QuizAttemptEntity> studentAttempts;
  final int attemptsRemaining;

  const QuizDetailLoaded({
    required this.quiz,
    required this.studentAttempts,
    required this.attemptsRemaining,
  });

  bool get canTakeQuiz => attemptsRemaining > 0 && quiz.isAvailable;
  QuizAttemptEntity? get bestAttempt {
    if (studentAttempts.isEmpty) return null;
    return studentAttempts.reduce((a, b) => a.score > b.score ? a : b);
  }

  QuizDetailLoaded copyWith({
    QuizEntity? quiz,
    List<QuizAttemptEntity>? studentAttempts,
    int? attemptsRemaining,
  }) {
    return QuizDetailLoaded(
      quiz: quiz ?? this.quiz,
      studentAttempts: studentAttempts ?? this.studentAttempts,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
    );
  }

  @override
  List<Object?> get props => [quiz, studentAttempts, attemptsRemaining];
}

class QuizDetailError extends QuizDetailState {
  final String message;

  const QuizDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
