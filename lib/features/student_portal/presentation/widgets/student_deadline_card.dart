import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/enrollment_entity.dart';

/// Interactive deadline and assignment submission tracking card.
class StudentDeadlineCard extends StatelessWidget {
  final StudentDeadlineItem item;
  final VoidCallback? onSubmit;

  const StudentDeadlineCard({
    super.key,
    required this.item,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final typeIcon = switch (item.type) {
      DeadlineType.assignment => Icons.assignment_outlined,
      DeadlineType.quiz => Icons.quiz_outlined,
      DeadlineType.project => Icons.code_rounded,
    };

    final typeColor = switch (item.type) {
      DeadlineType.assignment => AppColors.primary,
      DeadlineType.quiz => AppColors.warning,
      DeadlineType.project => AppColors.accentTeal,
    };

    final statusBgColor = switch (item.status) {
      DeadlineStatus.pending =>
        AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
      DeadlineStatus.submitted =>
        AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
      DeadlineStatus.graded =>
        AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
    };

    final statusTextColor = switch (item.status) {
      DeadlineStatus.pending => AppColors.warning,
      DeadlineStatus.submitted => AppColors.primary,
      DeadlineStatus.graded => AppColors.success,
    };

    final dueDays = item.dueDate.difference(DateTime.now()).inDays;
    final dueText = item.status == DeadlineStatus.graded
        ? 'Graded'
        : (dueDays == 0
            ? 'Due Today'
            : (dueDays == 1
                ? 'Due Tomorrow'
                : (dueDays > 1 ? 'Due in $dueDays days' : 'Past Due')));

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.courseCode,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '• ${item.points} pts',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dueText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: dueDays <= 1 && item.isPending
                        ? AppColors.error
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Status & Submission Action
          if (item.isPending && onSubmit != null)
            PortalButton(
              label: 'Submit',
              variant: PortalButtonVariant.outline,
              size: PortalButtonSize.sm,
              onPressed: onSubmit,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: Text(
                item.earnedGrade ?? item.status.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusTextColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
