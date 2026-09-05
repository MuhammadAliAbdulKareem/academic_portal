import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_analytics_state.dart';

class QuizAnalyticsCubit extends Cubit<QuizAnalyticsState> {
  final QuizRepository repository;

  QuizAnalyticsCubit({required this.repository})
      : super(const QuizAnalyticsInitial());

  Future<void> loadAnalytics(String quizId) async {
    emit(const QuizAnalyticsLoading());
    try {
      final quiz = await repository.getQuizById(quizId);
      final stats = await repository.getQuizStats(quizId);
      final attempts = await repository.getQuizRosterAttempts(quizId);

      emit(QuizAnalyticsLoaded(
        quiz: quiz,
        stats: stats,
        allAttempts: attempts,
        filteredAttempts: attempts,
      ));
    } catch (e) {
      emit(QuizAnalyticsError(e.toString()));
    }
  }

  void filterStudentSearch(String query) {
    if (state is! QuizAnalyticsLoaded) return;
    final current = state as QuizAnalyticsLoaded;
    final q = query.trim().toLowerCase();

    List<QuizAttemptEntity> filtered;
    if (q.isEmpty) {
      filtered = current.allAttempts;
    } else {
      filtered = current.allAttempts.where((attempt) {
        return attempt.studentName.toLowerCase().contains(q) ||
            attempt.studentId.toLowerCase().contains(q);
      }).toList();
    }

    emit(current.copyWith(
      searchFilter: query,
      filteredAttempts: filtered,
    ));
  }

  Future<void> refresh(String quizId) async {
    await loadAnalytics(quizId);
  }
}
