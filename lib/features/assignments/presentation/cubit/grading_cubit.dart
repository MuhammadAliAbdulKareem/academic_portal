import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import 'grading_state.dart';

class GradingCubit extends Cubit<GradingState> {
  final AssignmentRepository repository;

  GradingCubit({required this.repository}) : super(const GradingInitial());

  void initForSubmission(
    SubmissionEntity submission,
    List<AssignmentRubricItem> rubric,
  ) {
    final scores = <String, double>{};
    final levels = <String, String?>{};
    final comments = <String, String?>{};

    if (submission.rubricScores.isNotEmpty) {
      for (final rs in submission.rubricScores) {
        scores[rs.criterionId] = rs.awardedPoints;
        levels[rs.criterionId] = rs.selectedLevelTitle;
        comments[rs.criterionId] = rs.comments;
      }
    } else {
      for (final r in rubric) {
        scores[r.id] = r.maxPoints * 0.9; // Sensible 90% prefill default
      }
    }

    final total = scores.values.fold<double>(0.0, (acc, s) => acc + s);

    emit(
      GradingLoaded(
        submission: submission,
        rubric: rubric,
        criterionScores: scores,
        criterionSelectedLevels: levels,
        criterionComments: comments,
        totalScore: submission.score ?? total,
        feedbackNotes: submission.feedbackNotes ?? '',
      ),
    );
  }

  void updateCriterionScore(
    String criterionId,
    double score, {
    String? levelTitle,
  }) {
    if (state is! GradingLoaded) return;
    final current = state as GradingLoaded;

    final updatedScores = Map<String, double>.from(current.criterionScores);
    final updatedLevels = Map<String, String?>.from(current.criterionSelectedLevels);

    updatedScores[criterionId] = score;
    if (levelTitle != null) {
      updatedLevels[criterionId] = levelTitle;
    }

    final newTotal = updatedScores.values.fold<double>(0.0, (acc, s) => acc + s);

    emit(
      current.copyWith(
        criterionScores: updatedScores,
        criterionSelectedLevels: updatedLevels,
        totalScore: newTotal,
      ),
    );
  }

  void updateOverallScore(double score) {
    if (state is! GradingLoaded) return;
    final current = state as GradingLoaded;
    emit(current.copyWith(totalScore: score));
  }

  void updateFeedbackNotes(String notes) {
    if (state is! GradingLoaded) return;
    final current = state as GradingLoaded;
    emit(current.copyWith(feedbackNotes: notes));
  }

  Future<void> publishGrade({required String gradedBy}) async {
    if (state is! GradingLoaded) return;
    final current = state as GradingLoaded;

    emit(current.copyWith(isPublishing: true));

    try {
      final rubricScores = <RubricScore>[];
      for (final r in current.rubric) {
        final awarded = current.criterionScores[r.id] ?? 0.0;
        final lvl = current.criterionSelectedLevels[r.id];
        final cmt = current.criterionComments[r.id];
        rubricScores.add(
          RubricScore(
            criterionId: r.id,
            criterionTitle: r.title,
            awardedPoints: awarded,
            maxPoints: r.maxPoints,
            selectedLevelTitle: lvl,
            comments: cmt,
          ),
        );
      }

      final updated = await repository.gradeSubmission(
        submissionId: current.submission.id,
        score: current.totalScore,
        feedback: current.feedbackNotes,
        rubricScores: rubricScores,
        gradedBy: gradedBy,
      );

      emit(GradingSuccess(updated));
    } catch (e) {
      emit(GradingFailure('Failed to publish grade: ${e.toString()}'));
    }
  }
}
