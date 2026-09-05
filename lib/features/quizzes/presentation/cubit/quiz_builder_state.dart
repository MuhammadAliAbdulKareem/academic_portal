import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_entity.dart';

abstract class QuizBuilderState extends Equatable {
  const QuizBuilderState();

  @override
  List<Object?> get props => [];
}

class QuizBuilderInitial extends QuizBuilderState {
  const QuizBuilderInitial();
}

class QuizBuilderEditing extends QuizBuilderState {
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String description;
  final int timeLimitMinutes;
  final double passingPercentage;
  final int maxAttempts;
  final bool isPublished;
  final bool shuffleQuestions;
  final bool allowReview;
  final DateTime dueDate;
  final List<QuizQuestionEntity> questions;
  final bool isSaving;

  const QuizBuilderEditing({
    this.courseId = 'course_cs101',
    this.courseCode = 'CS101',
    this.courseTitle = 'Introduction to Computer Science & Algorithms',
    this.title = '',
    this.description = '',
    this.timeLimitMinutes = 20,
    this.passingPercentage = 70.0,
    this.maxAttempts = 1,
    this.isPublished = true,
    this.shuffleQuestions = false,
    this.allowReview = true,
    required this.dueDate,
    this.questions = const [],
    this.isSaving = false,
  });

  int get computedTotalPoints =>
      questions.fold<int>(0, (sum, q) => sum + q.points);

  QuizBuilderEditing copyWith({
    String? courseId,
    String? courseCode,
    String? courseTitle,
    String? title,
    String? description,
    int? timeLimitMinutes,
    double? passingPercentage,
    int? maxAttempts,
    bool? isPublished,
    bool? shuffleQuestions,
    bool? allowReview,
    DateTime? dueDate,
    List<QuizQuestionEntity>? questions,
    bool? isSaving,
  }) {
    return QuizBuilderEditing(
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isPublished: isPublished ?? this.isPublished,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      allowReview: allowReview ?? this.allowReview,
      dueDate: dueDate ?? this.dueDate,
      questions: questions ?? this.questions,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
        courseId,
        courseCode,
        courseTitle,
        title,
        description,
        timeLimitMinutes,
        passingPercentage,
        maxAttempts,
        isPublished,
        shuffleQuestions,
        allowReview,
        dueDate,
        questions,
        isSaving,
      ];
}

class QuizBuilderSaved extends QuizBuilderState {
  final QuizEntity createdQuiz;

  const QuizBuilderSaved(this.createdQuiz);

  @override
  List<Object?> get props => [createdQuiz];
}

class QuizBuilderError extends QuizBuilderState {
  final String message;

  const QuizBuilderError(this.message);

  @override
  List<Object?> get props => [message];
}
