import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/quiz_entity.dart';

class QuestionPaletteWidget extends StatelessWidget {
  final List<QuizQuestionEntity> questions;
  final int currentIndex;
  final Map<String, dynamic> answers;
  final Set<String> flaggedIds;
  final ValueChanged<int> onSelectQuestion;

  const QuestionPaletteWidget({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.flaggedIds,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question Palette',
              style: AppTypography.titleSmall.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${answers.length} of ${questions.length} answered',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Legend row
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _buildLegendItem(
              color: AppColors.success,
              label: 'Answered',
              isDark: isDark,
            ),
            _buildLegendItem(
              color: AppColors.warning,
              label: 'Flagged',
              isDark: isDark,
            ),
            _buildLegendItem(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              label: 'Unanswered',
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Grid of numbered question buttons
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: List.generate(questions.length, (index) {
            final q = questions[index];
            final isCurrent = index == currentIndex;
            final isAnswered = answers.containsKey(q.id);
            final isFlagged = flaggedIds.contains(q.id);

            Color bgColor;
            Color textColor;
            Border? border;

            if (isCurrent) {
              bgColor = AppColors.primary;
              textColor = Colors.white;
              border = Border.all(color: AppColors.primary, width: 2);
            } else if (isFlagged) {
              bgColor = AppColors.warning.withValues(alpha: isDark ? 0.3 : 0.15);
              textColor = AppColors.warning;
              border = Border.all(color: AppColors.warning, width: 1.5);
            } else if (isAnswered) {
              bgColor = AppColors.success.withValues(alpha: isDark ? 0.25 : 0.15);
              textColor = AppColors.success;
              border = Border.all(color: AppColors.success, width: 1.5);
            } else {
              bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
              textColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
              border = Border.all(color: isDark ? AppColors.darkBorder : AppColors.border);
            }

            return InkWell(
              onTap: () => onSelectQuestion(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: border,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${index + 1}',
                      style: AppTypography.labelMedium.copyWith(
                        color: textColor,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (isFlagged && !isCurrent)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Icon(
                          Icons.flag,
                          size: 10,
                          color: AppColors.warning,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
