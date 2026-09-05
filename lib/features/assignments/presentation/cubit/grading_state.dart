import 'package:equatable/equatable.dart';
import '../../domain/entities/assignment_entity.dart';

abstract class GradingState extends Equatable {
  const GradingState();

  @override
  List<Object?> get props => [];
}

class GradingInitial extends GradingState {
  const GradingInitial();
}

class GradingLoaded extends GradingState {
  final SubmissionEntity submission;
  final List<AssignmentRubricItem> rubric;
  final Map<String, double> criterionScores;
  final Map<String, String?> criterionSelectedLevels;
  final Map<String, String?> criterionComments;
  final double totalScore;
  final String feedbackNotes;
  final bool isPublishing;

  const GradingLoaded({
    required this.submission,
    required this.rubric,
    required this.criterionScores,
    this.criterionSelectedLevels = const {},
    this.criterionComments = const {},
    required this.totalScore,
    this.feedbackNotes = '',
    this.isPublishing = false,
  });

  GradingLoaded copyWith({
    SubmissionEntity? submission,
    List<AssignmentRubricItem>? rubric,
    Map<String, double>? criterionScores,
    Map<String, String?>? criterionSelectedLevels,
    Map<String, String?>? criterionComments,
    double? totalScore,
    String? feedbackNotes,
    bool? isPublishing,
  }) {
    return GradingLoaded(
      submission: submission ?? this.submission,
      rubric: rubric ?? this.rubric,
      criterionScores: criterionScores ?? this.criterionScores,
      criterionSelectedLevels: criterionSelectedLevels ?? this.criterionSelectedLevels,
      criterionComments: criterionComments ?? this.criterionComments,
      totalScore: totalScore ?? this.totalScore,
      feedbackNotes: feedbackNotes ?? this.feedbackNotes,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }

  @override
  List<Object?> get props => [
        submission,
        rubric,
        criterionScores,
        criterionSelectedLevels,
        criterionComments,
        totalScore,
        feedbackNotes,
        isPublishing,
      ];
}

class GradingSuccess extends GradingState {
  final SubmissionEntity submission;

  const GradingSuccess(this.submission);

  @override
  List<Object?> get props => [submission];
}

class GradingFailure extends GradingState {
  final String message;

  const GradingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
