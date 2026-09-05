import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_entity.dart';

abstract class QuizAnalyticsState extends Equatable {
  const QuizAnalyticsState();

  @override
  List<Object?> get props => [];
}

class QuizAnalyticsInitial extends QuizAnalyticsState {
  const QuizAnalyticsInitial();
}

class QuizAnalyticsLoading extends QuizAnalyticsState {
  const QuizAnalyticsLoading();
}

class QuizAnalyticsLoaded extends QuizAnalyticsState {
  final QuizEntity quiz;
  final QuizSummaryStatsEntity stats;
  final List<QuizAttemptEntity> allAttempts;
  final List<QuizAttemptEntity> filteredAttempts;
  final String searchFilter;

  const QuizAnalyticsLoaded({
    required this.quiz,
    required this.stats,
    required this.allAttempts,
    required this.filteredAttempts,
    this.searchFilter = '',
  });

  QuizAnalyticsLoaded copyWith({
    QuizEntity? quiz,
    QuizSummaryStatsEntity? stats,
    List<QuizAttemptEntity>? allAttempts,
    List<QuizAttemptEntity>? filteredAttempts,
    String? searchFilter,
  }) {
    return QuizAnalyticsLoaded(
      quiz: quiz ?? this.quiz,
      stats: stats ?? this.stats,
      allAttempts: allAttempts ?? this.allAttempts,
      filteredAttempts: filteredAttempts ?? this.filteredAttempts,
      searchFilter: searchFilter ?? this.searchFilter,
    );
  }

  @override
  List<Object?> get props => [
        quiz,
        stats,
        allAttempts,
        filteredAttempts,
        searchFilter,
      ];
}

class QuizAnalyticsError extends QuizAnalyticsState {
  final String message;

  const QuizAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
