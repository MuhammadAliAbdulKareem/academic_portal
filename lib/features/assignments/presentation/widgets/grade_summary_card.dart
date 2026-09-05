import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/assignment_entity.dart';

class GradeSummaryCard extends StatelessWidget {
  final SubmissionEntity submission;

  const GradeSummaryCard({
    super.key,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final score = submission.score ?? 0.0;
    final maxScore = submission.maxScore ?? 100.0;
    final pct = submission.scorePercentage;
    final letter = submission.letterGrade;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evaluation Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Graded by ${submission.gradedBy ?? "Instructor"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: AppSpacing.roundedMd,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Grade $letter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Score bar & percent
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score Earned',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)} pts (${pct.toStringAsFixed(1)}%)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (pct / 100.0).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.black26 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 85
                          ? AppColors.success
                          : (pct >= 70 ? AppColors.warning : AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Feedback notes
          if (submission.feedbackNotes != null && submission.feedbackNotes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Instructor Feedback',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: AppSpacing.roundedMd,
                border: const Border(
                  left: BorderSide(
                    color: AppColors.primary,
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                submission.feedbackNotes!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
