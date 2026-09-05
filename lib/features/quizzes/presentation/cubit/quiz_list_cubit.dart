import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_list_state.dart';

class QuizListCubit extends Cubit<QuizListState> {
  final QuizRepository repository;

  QuizListCubit({required this.repository}) : super(const QuizListInitial());

  Future<void> loadQuizzes({String? courseId, String? studentId}) async {
    emit(const QuizListLoading());
    try {
      final quizzes = await repository.getAllQuizzes(courseId: courseId, studentId: studentId);
      emit(QuizListLoaded(
        allQuizzes: quizzes,
        filteredQuizzes: quizzes,
        selectedCourseId: courseId,
      ));
    } catch (e) {
      emit(QuizListError(e.toString()));
    }
  }

  void searchQuizzes(String query) {
    if (state is! QuizListLoaded) return;
    final current = state as QuizListLoaded;
    final updated = current.copyWith(searchQuery: query);
    emit(_applyFilters(updated));
  }

  void filterByCourse(String? courseId) {
    if (state is! QuizListLoaded) return;
    final current = state as QuizListLoaded;
    final updated = current.copyWith(
      selectedCourseId: courseId,
      clearCourse: courseId == null,
    );
    emit(_applyFilters(updated));
  }

  void setFilterStatus(QuizFilterStatus status) {
    if (state is! QuizListLoaded) return;
    final current = state as QuizListLoaded;
    final updated = current.copyWith(filterStatus: status);
    emit(_applyFilters(updated));
  }

  QuizListLoaded _applyFilters(QuizListLoaded current) {
    var list = List<QuizEntity>.from(current.allQuizzes);

    // Course filter
    if (current.selectedCourseId != null && current.selectedCourseId!.isNotEmpty) {
      list = list.where((q) => q.courseId == current.selectedCourseId).toList();
    }

    // Status filter
    final now = DateTime.now();
    switch (current.filterStatus) {
      case QuizFilterStatus.all:
        break;
      case QuizFilterStatus.active:
        list = list.where((q) => q.isPublished && now.isBefore(q.dueDate)).toList();
        break;
      case QuizFilterStatus.completed:
        list = list.where((q) => now.isAfter(q.dueDate)).toList();
        break;
      case QuizFilterStatus.draft:
        list = list.where((q) => !q.isPublished).toList();
        break;
    }

    // Search query
    if (current.searchQuery.trim().isNotEmpty) {
      final q = current.searchQuery.trim().toLowerCase();
      list = list.where((quiz) {
        return quiz.title.toLowerCase().contains(q) ||
            quiz.courseCode.toLowerCase().contains(q) ||
            quiz.description.toLowerCase().contains(q);
      }).toList();
    }

    return current.copyWith(filteredQuizzes: list);
  }

  Future<void> refresh() async {
    if (state is QuizListLoaded) {
      final current = state as QuizListLoaded;
      try {
        final quizzes = await repository.getAllQuizzes(courseId: current.selectedCourseId);
        emit(_applyFilters(current.copyWith(allQuizzes: quizzes)));
      } catch (e) {
        emit(QuizListError(e.toString()));
      }
    } else {
      await loadQuizzes();
    }
  }
}
