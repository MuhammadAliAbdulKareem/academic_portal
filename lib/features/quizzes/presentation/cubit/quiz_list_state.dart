import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_entity.dart';

enum QuizFilterStatus { all, active, completed, draft }

abstract class QuizListState extends Equatable {
  const QuizListState();

  @override
  List<Object?> get props => [];
}

class QuizListInitial extends QuizListState {
  const QuizListInitial();
}

class QuizListLoading extends QuizListState {
  const QuizListLoading();
}

class QuizListLoaded extends QuizListState {
  final List<QuizEntity> allQuizzes;
  final List<QuizEntity> filteredQuizzes;
  final String searchQuery;
  final String? selectedCourseId;
  final QuizFilterStatus filterStatus;

  const QuizListLoaded({
    required this.allQuizzes,
    required this.filteredQuizzes,
    this.searchQuery = '',
    this.selectedCourseId,
    this.filterStatus = QuizFilterStatus.all,
  });

  QuizListLoaded copyWith({
    List<QuizEntity>? allQuizzes,
    List<QuizEntity>? filteredQuizzes,
    String? searchQuery,
    String? selectedCourseId,
    bool clearCourse = false,
    QuizFilterStatus? filterStatus,
  }) {
    return QuizListLoaded(
      allQuizzes: allQuizzes ?? this.allQuizzes,
      filteredQuizzes: filteredQuizzes ?? this.filteredQuizzes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourseId: clearCourse ? null : (selectedCourseId ?? this.selectedCourseId),
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  @override
  List<Object?> get props => [
        allQuizzes,
        filteredQuizzes,
        searchQuery,
        selectedCourseId,
        filterStatus,
      ];
}

class QuizListError extends QuizListState {
  final String message;

  const QuizListError(this.message);

  @override
  List<Object?> get props => [message];
}
