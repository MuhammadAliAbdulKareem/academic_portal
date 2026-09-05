import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/assignment_entity.dart';

class SubmissionItemCard extends StatelessWidget {
  final SubmissionEntity submission;
  final VoidCallback onGrade;

  const SubmissionItemCard({
    super.key,
    required this.submission,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info & Status
          Row(
            children: [
              PortalAvatar(
                name: submission.studentName,
                imageUrl: submission.studentAvatar,
                size: PortalAvatarSize.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.studentName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      submission.studentEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (submission.isGraded)
                PortalBadge(
                  label: '${submission.score?.toInt()}/${submission.maxScore?.toInt()} pts (${submission.letterGrade})',
                  variant: PortalBadgeVariant.success,
                  icon: Icons.check_circle_rounded,
                )
              else
                const PortalBadge(
                  label: 'Needs Grading',
                  variant: PortalBadgeVariant.warning,
                  icon: Icons.pending_rounded,
                  hasDot: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // File / Text response preview
          if (submission.fileName != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_file_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${submission.fileName} (${submission.formattedFileSize})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (submission.textResponse != null && submission.textResponse!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              submission.textResponse!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Footer info & grade button
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Submitted: ${submission.submittedAt.month}/${submission.submittedAt.day} at ${submission.submittedAt.hour}:${submission.submittedAt.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              PortalButton(
                label: submission.isGraded ? 'Review & Edit Grade' : 'Grade Submission',
                variant: submission.isGraded
                    ? PortalButtonVariant.outline
                    : PortalButtonVariant.primary,
                size: PortalButtonSize.sm,
                icon: Icons.rate_review_outlined,
                onPressed: onGrade,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
