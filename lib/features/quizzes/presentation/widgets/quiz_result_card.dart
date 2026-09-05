import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
                        style: TextStyle(
                          fontSize: 22,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isPassed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          fontSize: 10,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                quiz.courseTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.primaryLight),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          attempt.feedback!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Correct Answer: ${_formatCorrectAnswer(q)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
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
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              q.explanation,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
