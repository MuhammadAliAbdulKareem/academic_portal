import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/assignment_entity.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentEntity assignment;
  final SubmissionEntity? submission;
  final bool isInstructor;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.submission,
    this.isInstructor = false,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine status badge
    PortalBadgeVariant statusVariant;
    String statusLabel;
    IconData statusIcon;

    if (submission != null && submission!.isGraded) {
      statusVariant = PortalBadgeVariant.success;
      statusLabel = 'Graded (${submission!.score?.toInt()}/${submission!.maxScore?.toInt()} pts)';
      statusIcon = Icons.check_circle_rounded;
    } else if (submission != null && submission!.status == SubmissionStatus.submitted) {
      statusVariant = PortalBadgeVariant.info;
      statusLabel = 'Submitted';
      statusIcon = Icons.task_alt_rounded;
    } else if (assignment.isOverdue) {
      statusVariant = PortalBadgeVariant.error;
      statusLabel = 'Past Due';
      statusIcon = Icons.timer_off_rounded;
    } else {
      statusVariant = PortalBadgeVariant.warning;
      statusLabel = '${assignment.daysRemaining} days left';
      statusIcon = Icons.access_time_rounded;
    }

    String actionButtonLabel;
    PortalButtonVariant actionButtonVariant;
    IconData actionButtonIcon;

    if (isInstructor) {
      actionButtonLabel = 'Grade Submissions';
      actionButtonVariant = PortalButtonVariant.primary;
      actionButtonIcon = Icons.rate_review_rounded;
    } else if (submission != null && submission!.isGraded) {
      actionButtonLabel = 'View Feedback';
      actionButtonVariant = PortalButtonVariant.outline;
      actionButtonIcon = Icons.visibility_rounded;
    } else if (submission != null) {
      actionButtonLabel = 'View Submission';
      actionButtonVariant = PortalButtonVariant.secondary;
      actionButtonIcon = Icons.description_rounded;
    } else {
      actionButtonLabel = 'Submit Work';
      actionButtonVariant = PortalButtonVariant.primary;
      actionButtonIcon = Icons.file_upload_rounded;
    }

    return PortalCard(
      isHoverable: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header wrap to prevent overflow
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PortalBadge(
                    label: assignment.courseCode,
                    variant: PortalBadgeVariant.primary,
                    icon: Icons.school_outlined,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  PortalBadge(
                    label: '${assignment.weightPercentage.toInt()}% Weight',
                    variant: PortalBadgeVariant.neutral,
                  ),
                ],
              ),
              PortalBadge(
                label: statusLabel,
                variant: statusVariant,
                icon: statusIcon,
                hasDot: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Title
          Text(
            assignment.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Truncated Description
          Text(
            assignment.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // Footer info wrap
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${assignment.dueDate.month}/${assignment.dueDate.day}/${assignment.dueDate.year}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_outline_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${assignment.totalPoints.toInt()} pts',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
              if (assignment.rubric.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 16,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${assignment.rubric.length} Rubric Criteria',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: PortalButton(
              label: actionButtonLabel,
              variant: actionButtonVariant,
              size: PortalButtonSize.sm,
              icon: actionButtonIcon,
              onPressed: onAction ?? onTap,
            ),
          ),
        ],
      ),
    );
  }
}
