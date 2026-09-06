import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/discussion_entity.dart';

class DiscussionReplyCard extends StatelessWidget {
  final DiscussionReplyEntity reply;
  final String? currentUserId;
  final bool isCurrentUserInstructor;
  final VoidCallback onUpvote;
  final VoidCallback onToggleEndorsement;

  const DiscussionReplyCard({
    super.key,
    required this.reply,
    this.currentUserId,
    this.isCurrentUserInstructor = false,
    required this.onUpvote,
    required this.onToggleEndorsement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUpvoted = currentUserId != null && reply.hasUpvoted(currentUserId!);

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If Instructor Endorsed: Top Banner
          if (reply.isInstructorEndorsed) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(25),
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.warning.withAlpha(120)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'VERIFIED FACULTY SOLUTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Author Row
          Row(
            children: [
              PortalAvatar(
                name: reply.authorName,
                imageUrl: reply.authorAvatar,
                size: PortalAvatarSize.sm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          reply.authorName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        PortalBadge(
                          label: reply.authorRole.toUpperCase(),
                          variant: reply.authorRole.toLowerCase().contains('instructor') ||
                                  reply.authorRole.toLowerCase().contains('faculty')
                              ? PortalBadgeVariant.instructor
                              : PortalBadgeVariant.student,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(reply.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isCurrentUserInstructor)
                PortalButton(
                  label: reply.isInstructorEndorsed ? 'Remove Endorsement' : 'Endorse Solution',
                  icon: reply.isInstructorEndorsed ? Icons.close_rounded : Icons.verified_rounded,
                  size: PortalButtonSize.sm,
                  variant: reply.isInstructorEndorsed
                      ? PortalButtonVariant.outline
                      : PortalButtonVariant.secondary,
                  onPressed: onToggleEndorsement,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Reply Content
          _buildFormattedContent(context, reply.content, isDark),
          const SizedBox(height: AppSpacing.md),

          // Upvote and Interaction Row
          Row(
            children: [
              InkWell(
                onTap: onUpvote,
                borderRadius: AppSpacing.roundedSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasUpvoted
                        ? AppColors.primary.withAlpha(35)
                        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: hasUpvoted
                          ? AppColors.primaryLight
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                        size: 14,
                        color: hasUpvoted
                            ? AppColors.primaryLight
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Helpful (${reply.upvotes})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: hasUpvoted ? FontWeight.bold : FontWeight.w500,
                          color: hasUpvoted
                              ? AppColors.primaryLight
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(BuildContext context, String content, bool isDark) {
    if (content.contains('```')) {
      final parts = content.split('```');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts.asMap().entries.map((entry) {
          final idx = entry.key;
          final text = entry.value;

          if (idx % 2 == 1) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                text.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF38BDF8),
                  height: 1.4,
                ),
              ),
            );
          } else {
            if (text.trim().isEmpty) return const SizedBox.shrink();
            return Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            );
          }
        }).toList(),
      );
    }

    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
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
