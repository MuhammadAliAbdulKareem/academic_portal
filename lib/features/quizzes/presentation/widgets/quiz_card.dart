import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final bool isInstructor;
  final VoidCallback? onTap;
  final VoidCallback? onTakeQuiz;
  final VoidCallback? onAnalytics;

  const QuizCard({
    super.key,
    required this.quiz,
    this.isInstructor = false,
    this.onTap,
    this.onTakeQuiz,
    this.onAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final isPast = now.isAfter(quiz.dueDate);
    final isOpen = quiz.isPublished && !isPast && now.isAfter(quiz.availableFrom);

    return PortalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Course Code Badge + Status Pill
          Row(
            children: [
              PortalBadge(
                label: quiz.courseCode,
                variant: PortalBadgeVariant.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  quiz.courseTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!quiz.isPublished)
                const PortalBadge(
                  label: 'Draft',
                  variant: PortalBadgeVariant.neutral,
                )
              else if (isPast)
                const PortalBadge(
                  label: 'Closed',
                  variant: PortalBadgeVariant.error,
                )
              else if (isOpen)
                const PortalBadge(
                  label: 'Open Now',
                  variant: PortalBadgeVariant.success,
                )
              else
                const PortalBadge(
                  label: 'Upcoming',
                  variant: PortalBadgeVariant.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            quiz.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Description
          Text(
            quiz.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // Metadata Chips Row
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _buildMetaChip(
                icon: Icons.timer_outlined,
                label: quiz.timeLimitFormatted,
                isDark: isDark,
              ),
              _buildMetaChip(
                icon: Icons.quiz_outlined,
                label: '${quiz.questionsCount} Questions',
                isDark: isDark,
              ),
              _buildMetaChip(
                icon: Icons.stars_outlined,
                label: '${quiz.totalPoints} Pts',
                isDark: isDark,
              ),
              _buildMetaChip(
                icon: Icons.check_circle_outline,
                label: 'Pass: ${quiz.passingPercentage.toStringAsFixed(0)}%',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Due Date
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Due ${quiz.dueDate.day}/${quiz.dueDate.month}/${quiz.dueDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              if (isInstructor)
                PortalButton(
                  label: 'Analytics',
                  icon: Icons.insights,
                  size: PortalButtonSize.sm,
                  variant: PortalButtonVariant.secondary,
                  onPressed: onAnalytics,
                )
              else if (isOpen)
                PortalButton(
                  label: 'Start Quiz',
                  icon: Icons.play_arrow_rounded,
                  size: PortalButtonSize.sm,
                  variant: PortalButtonVariant.primary,
                  onPressed: onTakeQuiz,
                )
              else
                PortalButton(
                  label: 'View Details',
                  size: PortalButtonSize.sm,
                  variant: PortalButtonVariant.ghost,
                  onPressed: onTap,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
