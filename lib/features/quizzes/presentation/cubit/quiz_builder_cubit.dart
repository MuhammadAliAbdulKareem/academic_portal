import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_builder_state.dart';

class QuizBuilderCubit extends Cubit<QuizBuilderState> {
  final QuizRepository repository;

  QuizBuilderCubit({required this.repository})
      : super(QuizBuilderEditing(dueDate: DateTime.now().add(const Duration(days: 7))));

  void initNewQuiz() {
    emit(QuizBuilderEditing(dueDate: DateTime.now().add(const Duration(days: 7))));
  }

  void updateCourseInfo({
    required String courseId,
    required String courseCode,
    required String courseTitle,
  }) {
    if (state is! QuizBuilderEditing) return;
    final current = state as QuizBuilderEditing;
    emit(current.copyWith(
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
    ));
  }

  void updateBasicDetails({
    String? title,
    String? description,
    int? timeLimitMinutes,
    double? passingPercentage,
    int? maxAttempts,
    bool? isPublished,
    bool? shuffleQuestions,
    bool? allowReview,
    DateTime? dueDate,
  }) {
    if (state is! QuizBuilderEditing) return;
    final current = state as QuizBuilderEditing;
    emit(current.copyWith(
      title: title,
      description: description,
      timeLimitMinutes: timeLimitMinutes,
      passingPercentage: passingPercentage,
      maxAttempts: maxAttempts,
      isPublished: isPublished,
      shuffleQuestions: shuffleQuestions,
      allowReview: allowReview,
      dueDate: dueDate,
    ));
  }

  void addQuestion(QuizQuestionEntity question) {
    if (state is! QuizBuilderEditing) return;
    final current = state as QuizBuilderEditing;
    final updatedList = List<QuizQuestionEntity>.from(current.questions)..add(question);
    emit(current.copyWith(questions: updatedList));
  }

  void removeQuestion(String questionId) {
    if (state is! QuizBuilderEditing) return;
    final current = state as QuizBuilderEditing;
    final updatedList = current.questions.where((q) => q.id != questionId).toList();
    emit(current.copyWith(questions: updatedList));
  }

  void updateQuestion(QuizQuestionEntity question) {
    if (state is! QuizBuilderEditing) return;
    final current = state as QuizBuilderEditing;
    final updatedList = current.questions.map((q) => q.id == question.id ? question : q).toList();
    emit(current.copyWith(questions: updatedList));
  }

  Future<void> saveQuiz() async {
    if (state is! QuizBuilderEditing) return;
    final current = state as QuizBuilderEditing;

    if (current.title.trim().isEmpty) {
      emit(const QuizBuilderError('Please provide a quiz title.'));
      emit(current);
      return;
    }

    if (current.questions.isEmpty) {
      emit(const QuizBuilderError('Please add at least one question to the quiz.'));
      emit(current);
      return;
    }

    emit(current.copyWith(isSaving: true));

    try {
      final newQuiz = QuizEntity(
        id: '',
        courseId: current.courseId,
        courseCode: current.courseCode,
        courseTitle: current.courseTitle,
        title: current.title.trim(),
        description: current.description.trim(),
        timeLimitMinutes: current.timeLimitMinutes,
        totalPoints: current.computedTotalPoints,
        passingPercentage: current.passingPercentage,
        maxAttempts: current.maxAttempts,
        isPublished: current.isPublished,
        shuffleQuestions: current.shuffleQuestions,
        allowReview: current.allowReview,
        availableFrom: DateTime.now(),
        dueDate: current.dueDate,
        questionsCount: current.questions.length,
      );

      final created = await repository.createQuiz(
        quiz: newQuiz,
        questions: current.questions,
      );

      emit(QuizBuilderSaved(created));
    } catch (e) {
      emit(QuizBuilderError(e.toString()));
      emit(current.copyWith(isSaving: false));
    }
  }
}
