import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/course_entity.dart';

/// Card component rendering key metadata, schedule, and enrollment for a course.
class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback? onTap;
  final VoidCallback? onManage;
  final bool isEnrolled;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onManage,
    this.isEnrolled = false,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Code Badge + Department Pill + Optional Enrolled Badge
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  PortalBadge(
                    label: course.code,
                    variant: PortalBadgeVariant.primary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Text(
                      course.department,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  if (isEnrolled)
                    const PortalBadge(
                      label: 'ENROLLED',
                      variant: PortalBadgeVariant.instructor,
                      hasDot: true,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Instructor
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.instructorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Description snippet
              if (course.description.isNotEmpty)
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
            ],
          ),

          // Footer info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: AppSpacing.lg),

              // Schedule & Room
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.schedule,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 2,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.12),
                      borderRadius: AppSpacing.roundedSm,
                    ),
                    child: Text(
                      '${course.credits} Credits',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Enrollment progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enrollment',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  Text(
                    '${course.enrolledCount}/${course.maxCapacity}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: course.isFull
                          ? AppColors.error
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: AppSpacing.roundedFull,
                child: LinearProgressIndicator(
                  value: course.enrollmentRatio,
                  minHeight: 5,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.lightSurfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    course.isFull
                        ? AppColors.error
                        : (course.enrollmentRatio > 0.8
                            ? AppColors.accentAmber
                            : AppColors.primaryLight),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Action button
              SizedBox(
                width: double.infinity,
                child: PortalButton(
                  label: 'View Details',
                  variant: PortalButtonVariant.outline,
                  size: PortalButtonSize.sm,
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
