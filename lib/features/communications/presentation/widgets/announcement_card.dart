import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  final String? currentUserId;
  final VoidCallback? onAcknowledge;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.currentUserId,
    this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = currentUserId != null && announcement.isReadBy(currentUserId!);

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Priority badge, Course code, Pinned banner
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPriorityBadge(announcement.priority),
              const SizedBox(width: AppSpacing.xs),
              PortalBadge(
                label: announcement.courseCode,
                variant: PortalBadgeVariant.neutral,
              ),
              if (announcement.isPinned) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin_rounded, size: 12, color: AppColors.primaryLight),
                      SizedBox(width: 4),
                      Text(
                        'PINNED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (!isRead && currentUserId != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Title
          Text(
            announcement.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Author and Date Row
          Row(
            children: [
              PortalAvatar(
                name: announcement.authorName,
                imageUrl: announcement.authorAvatar,
                size: PortalAvatarSize.sm,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${announcement.authorName} (${announcement.authorRole})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '• ${_formatDate(announcement.publishedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Body Content
          Text(
            announcement.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Tags & Actions Row
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: announcement.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface.withAlpha(180)
                            : AppColors.lightSurface,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (!isRead && onAcknowledge != null)
                PortalButton(
                  label: 'Mark as Read',
                  icon: Icons.check_circle_outline_rounded,
                  size: PortalButtonSize.sm,
                  variant: PortalButtonVariant.outline,
                  onPressed: onAcknowledge,
                )
              else if (isRead && currentUserId != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Read',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return const PortalBadge(
          label: 'URGENT',
          variant: PortalBadgeVariant.error,
        );
      case AnnouncementPriority.academic:
        return const PortalBadge(
          label: 'ACADEMIC',
          variant: PortalBadgeVariant.primary,
        );
      case AnnouncementPriority.examNotice:
        return const PortalBadge(
          label: 'EXAM NOTICE',
          variant: PortalBadgeVariant.warning,
        );
      case AnnouncementPriority.general:
        return const PortalBadge(
          label: 'GENERAL',
          variant: PortalBadgeVariant.secondary,
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
