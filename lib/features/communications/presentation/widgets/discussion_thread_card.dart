import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/discussion_entity.dart';

class DiscussionThreadCard extends StatelessWidget {
  final DiscussionThreadEntity thread;
  final VoidCallback onTap;

  const DiscussionThreadCard({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PortalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row: Course, Category, Verified badge, Pinned
          Row(
            children: [
              PortalBadge(
                label: thread.courseCode,
                variant: PortalBadgeVariant.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildCategoryBadge(thread.category),
              if (thread.isPinned) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primaryLight),
              ],
              const Spacer(),
              if (thread.hasInstructorEndorsement)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(30),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.warning.withAlpha(120)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        'FACULTY VERIFIED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                )
              else if (thread.isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.success.withAlpha(120)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'RESOLVED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Title
          Text(
            thread.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Content snippet
          Text(
            thread.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Footer: Author & Replies Counter
          Row(
            children: [
              PortalAvatar(
                name: thread.authorName,
                imageUrl: thread.authorAvatar,
                size: PortalAvatarSize.sm,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                thread.authorName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '• ${_formatDate(thread.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${thread.repliesCount} replies',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(DiscussionCategory category) {
    switch (category) {
      case DiscussionCategory.homeworkHelp:
        return const PortalBadge(
          label: 'Homework Help',
          variant: PortalBadgeVariant.secondary,
        );
      case DiscussionCategory.examPrep:
        return const PortalBadge(
          label: 'Exam Prep',
          variant: PortalBadgeVariant.warning,
        );
      case DiscussionCategory.projectCollab:
        return const PortalBadge(
          label: 'Project Collab',
          variant: PortalBadgeVariant.primary,
        );
      case DiscussionCategory.technicalQuestions:
        return const PortalBadge(
          label: 'Technical Q&A',
          variant: PortalBadgeVariant.neutral,
        );
      case DiscussionCategory.general:
        return const PortalBadge(
          label: 'General',
          variant: PortalBadgeVariant.neutral,
        );
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
