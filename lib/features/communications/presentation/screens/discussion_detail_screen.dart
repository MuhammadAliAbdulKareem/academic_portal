import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/discussion_entity.dart';
import '../cubit/discussion_detail_cubit.dart';
import '../cubit/discussion_detail_state.dart';
import '../widgets/discussion_reply_card.dart';

class DiscussionDetailScreen extends StatefulWidget {
  final String threadId;

  const DiscussionDetailScreen({super.key, required this.threadId});

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DiscussionDetailCubit>().loadThread(widget.threadId);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthCubit>().state;
    final authorId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    final authorName = authState is Authenticated ? authState.user.displayName : 'Alex Mercer';
    final authorRole = authState is Authenticated ? authState.user.role.displayName : 'Student';
    final authorAvatar = authState is Authenticated ? authState.user.photoUrl : null;

    final reply = DiscussionReplyEntity(
      id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
      threadId: widget.threadId,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      content: text,
      createdAt: DateTime.now(),
      upvotes: 0,
      isInstructorEndorsed: false,
      upvotedByUserIds: const [],
    );

    context.read<DiscussionDetailCubit>().addReply(threadId: widget.threadId, reply: reply);
    _replyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final isInstructor = authState is Authenticated && authState.user.role.isInstructor;
    final currentUserId = authState is Authenticated ? authState.user.id : 'demo-student-01';

    return ResponsiveLayout(
      mobile: _buildContent(context, isDark, isInstructor, currentUserId, isMobile: true),
      desktop: _buildContent(context, isDark, isInstructor, currentUserId, isMobile: false),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    bool isInstructor,
    String currentUserId, {
    required bool isMobile,
  }) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Discussion Thread'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/discussions'),
        ),
      ),
      body: BlocBuilder<DiscussionDetailCubit, DiscussionDetailState>(
        builder: (context, state) {
          if (state is DiscussionDetailLoading) {
            return Padding(
              padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
              child: Column(
                children: [
                  PortalSkeleton.card(height: 220),
                  const SizedBox(height: AppSpacing.md),
                  PortalSkeleton.card(height: 120),
                ],
              ),
            );
          }

          if (state is DiscussionDetailError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load discussion: ${state.message}'),
                  const SizedBox(height: AppSpacing.sm),
                  PortalButton(
                    label: 'Back to Discussions',
                    onPressed: () => context.go('/discussions'),
                  ),
                ],
              ),
            );
          }

          if (state is DiscussionDetailLoaded) {
            final thread = state.thread;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Question Card
                  _buildThreadCard(context, thread, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // Replies Header
                  Row(
                    children: [
                      const Icon(Icons.chat_rounded, size: 20, color: AppColors.primaryLight),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Replies (${thread.replies.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (thread.hasInstructorEndorsement)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(25),
                            borderRadius: AppSpacing.roundedSm,
                            border: Border.all(color: AppColors.warning.withAlpha(120)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 13, color: AppColors.warning),
                              SizedBox(width: 4),
                              Text(
                                'Has Verified Answer',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Replies List
                  if (thread.replies.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Text(
                          'No replies yet. Be the first to answer!',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: thread.replies.map((reply) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DiscussionReplyCard(
                            reply: reply,
                            currentUserId: currentUserId,
                            isCurrentUserInstructor: isInstructor,
                            onUpvote: () {
                              context.read<DiscussionDetailCubit>().toggleUpvote(
                                    threadId: thread.id,
                                    replyId: reply.id,
                                    userId: currentUserId,
                                  );
                            },
                            onToggleEndorsement: () {
                              context.read<DiscussionDetailCubit>().toggleInstructorEndorsement(
                                    threadId: thread.id,
                                    replyId: reply.id,
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Reply Composer
                  _buildReplyComposer(context, isDark, state.isPostingReply),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildThreadCard(BuildContext context, DiscussionThreadEntity thread, bool isDark) {
    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PortalBadge(
                label: thread.courseCode,
                variant: PortalBadgeVariant.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              PortalBadge(
                label: thread.category.displayName,
                variant: PortalBadgeVariant.secondary,
              ),
              if (thread.isPinned) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primaryLight),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            thread.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              PortalAvatar(
                name: thread.authorName,
                imageUrl: thread.authorAvatar,
                size: PortalAvatarSize.sm,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${thread.authorName} (${thread.authorRole})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '• ${_formatDate(thread.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            thread.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          if (thread.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: thread.tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    '#$t',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyComposer(BuildContext context, bool isDark, bool isPosting) {
    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Answer / Reply',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _replyController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your explanation, hints, or code snippets with ```...',
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: PortalButton(
              label: 'Post Reply',
              icon: Icons.send_rounded,
              isLoading: isPosting,
              onPressed: _submitReply,
            ),
          ),
        ],
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
