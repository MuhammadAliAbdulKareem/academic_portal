import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizResultCard extends StatelessWidget {
  final QuizEntity quiz;
  final QuizAttemptEntity attempt;
  final List<QuizQuestionEntity> questions;
  final VoidCallback? onReturn;
  final VoidCallback? onRetake;
  final bool canRetake;

  const QuizResultCard({
    super.key,
    required this.quiz,
    required this.attempt,
    required this.questions,
    this.onReturn,
    this.onRetake,
    this.canRetake = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPassed = attempt.passed;
    final statusColor = isPassed ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Overview Card
        PortalCard(
          child: Column(
            children: [
              // Circular Percentage Gauge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  border: Border.all(color: statusColor, width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${attempt.percentage.toStringAsFixed(0)}%',
                        style: AppTypography.headlineSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isPassed ? 'PASSED' : 'FAILED',
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title & Course
              Text(
                quiz.title,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                quiz.courseTitle,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    label: 'Score',
                    value: '${attempt.score} / ${attempt.totalPossiblePoints}',
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildStatItem(
                    label: 'Passing Mark',
                    value: '${quiz.passingPercentage.toStringAsFixed(0)}%',
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildStatItem(
                    label: 'Time Taken',
                    value: attempt.timeTakenFormatted,
                    isDark: isDark,
                  ),
                ],
              ),

              if (attempt.feedback != null && attempt.feedback!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          attempt.feedback!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Questions Review Header
        if (quiz.allowReview) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'Question-by-Question Review',
              style: AppTypography.titleSmall.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Review Items
          ...List.generate(questions.length, (index) {
            final q = questions[index];
            final studentAnswer = attempt.answers[q.id];
            final isCorrect = q.isAnswerCorrect(studentAnswer);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PortalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question index + Correctness badge
                    Row(
                      children: [
                        Text(
                          'Question ${index + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        PortalBadge(
                          label: isCorrect ? 'Correct (+${q.points})' : 'Incorrect (0/${q.points})',
                          variant: isCorrect ? PortalBadgeVariant.success : PortalBadgeVariant.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Prompt
                    Text(
                      q.prompt,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Your Answer vs Correct Answer
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08)
                            : AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Answer: ${_formatAnswer(q, studentAnswer)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isCorrect ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Correct Answer: ${_formatCorrectAnswer(q)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Explanation
                    if (q.explanation.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              q.explanation,
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],

        // Action Buttons Row
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (canRetake && onRetake != null) ...[
              PortalButton(
                label: 'Retake Quiz',
                icon: Icons.replay,
                variant: PortalButtonVariant.secondary,
                onPressed: onRetake,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            PortalButton(
              label: 'Back to Quizzes',
              icon: Icons.check,
              variant: PortalButtonVariant.primary,
              onPressed: onReturn,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.border,
    );
  }

  String _formatAnswer(QuizQuestionEntity q, dynamic ans) {
    if (ans == null) return 'No answer given';
    if (q.type == QuestionType.singleChoice && ans is int) {
      if (ans >= 0 && ans < q.options.length) {
        return '${String.fromCharCode(65 + ans)}. ${q.options[ans]}';
      }
      return 'Option #$ans';
    }
    if (q.type == QuestionType.multipleChoice && ans is List) {
      return ans.map((idx) {
        if (idx is int && idx >= 0 && idx < q.options.length) {
          return '${String.fromCharCode(65 + idx)}. ${q.options[idx]}';
        }
        return idx.toString();
      }).join(', ');
    }
    if (q.type == QuestionType.trueFalse) {
      return ans == true ? 'True' : 'False';
    }
    return ans.toString();
  }

  String _formatCorrectAnswer(QuizQuestionEntity q) {
    if (q.type == QuestionType.singleChoice && q.correctAnswer is int) {
      final idx = q.correctAnswer as int;
      if (idx >= 0 && idx < q.options.length) {
        return '${String.fromCharCode(65 + idx)}. ${q.options[idx]}';
      }
    }
    if (q.type == QuestionType.multipleChoice) {
      return q.correctOptionIndices.map((idx) {
        if (idx >= 0 && idx < q.options.length) {
          return '${String.fromCharCode(65 + idx)}. ${q.options[idx]}';
        }
        return idx.toString();
      }).join(', ');
    }
    if (q.type == QuestionType.trueFalse) {
      return q.correctAnswer == true ? 'True' : 'False';
    }
    return q.correctAnswer?.toString() ?? 'N/A';
  }
}
