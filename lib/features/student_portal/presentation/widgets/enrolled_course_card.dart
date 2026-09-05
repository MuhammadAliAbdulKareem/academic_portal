import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/enrollment_entity.dart';

/// Card component showing an actively enrolled course with syllabus progress.
class EnrolledCourseCard extends StatelessWidget {
  final EnrollmentEntity enrollment;
  final VoidCallback onViewDetails;
  final VoidCallback? onDrop;

  const EnrolledCourseCard({
    super.key,
    required this.enrollment,
    required this.onViewDetails,
    this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      isHoverable: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Department, Term, and Grade
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  PortalBadge(
                    label: enrollment.department,
                    variant: PortalBadgeVariant.info,
                  ),
                  PortalBadge(
                    label: '${enrollment.credits} Credits',
                    variant: PortalBadgeVariant.neutral,
                  ),
                ],
              ),
              if (enrollment.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Text(
                    'Grade: ${enrollment.grade}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Course Code and Title
          Text(
            enrollment.courseCode,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            enrollment.courseTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Schedule & Room
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${enrollment.schedule} • ${enrollment.room}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Syllabus Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: 2,
                children: [
                  Text(
                    'Syllabus Progress',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  Text(
                    '${(enrollment.progressRatio * 100).toInt()}% • Mod ${enrollment.completedModules}/${enrollment.totalModules}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: AppSpacing.roundedFull,
                child: LinearProgressIndicator(
                  value: enrollment.progressRatio,
                  minHeight: 6,
                  backgroundColor:
                      isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: AppSpacing.lg),

          // Actions
          Row(
            children: [
              Expanded(
                child: PortalButton(
                  label: 'View Syllabus',
                  variant: PortalButtonVariant.secondary,
                  size: PortalButtonSize.sm,
                  icon: Icons.menu_book_rounded,
                  onPressed: onViewDetails,
                ),
              ),
              if (onDrop != null) ...[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                  tooltip: 'Drop Course',
                  onPressed: onDrop,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
