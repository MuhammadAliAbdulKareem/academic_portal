import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/assignment_entity.dart';
import '../cubit/assignment_detail_cubit.dart';
import '../cubit/assignment_detail_state.dart';
import '../cubit/grading_cubit.dart';
import '../cubit/grading_state.dart';
import '../widgets/rubric_scoring_widget.dart';

class AssignmentGradingScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentGradingScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentGradingScreen> createState() => _AssignmentGradingScreenState();
}

class _AssignmentGradingScreenState extends State<AssignmentGradingScreen> {
  int _selectedSubmissionIndex = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AssignmentDetailCubit>().loadAssignmentDetails(
          assignmentId: widget.assignmentId,
        );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _initGradingForSubmission(
    SubmissionEntity submission,
    List<AssignmentRubricItem> rubric,
  ) {
    context.read<GradingCubit>().initForSubmission(submission, rubric);
    _feedbackController.text = submission.feedbackNotes ?? '';
    _scoreController.text = (submission.score ?? (submission.maxScore ?? 100.0) * 0.9)
        .toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = context.watch<AuthCubit>().state;
    final instructorName =
        authState is Authenticated ? authState.user.displayName : 'Dr. Robert Vance';

    return PortalNavigationShell(
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Instructor Grading Cockpit',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: BlocConsumer<GradingCubit, GradingState>(
          listener: (context, gradeState) {
            if (gradeState is GradingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Grade published for ${gradeState.submission.studentName}: ${gradeState.submission.score?.toInt()}/${gradeState.submission.maxScore?.toInt()} pts (${gradeState.submission.letterGrade})',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadData();
            } else if (gradeState is GradingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(gradeState.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, gradeState) {
            return BlocConsumer<AssignmentDetailCubit, AssignmentDetailState>(
              listener: (context, state) {
                if (state is AssignmentDetailLoaded && state.allSubmissions.isNotEmpty) {
                  final safeIndex =
                      _selectedSubmissionIndex.clamp(0, state.allSubmissions.length - 1);
                  final selectedSub = state.allSubmissions[safeIndex];
                  _initGradingForSubmission(selectedSub, state.assignment.rubric);
                }
              },
              builder: (context, state) {
                if (state is AssignmentDetailLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        PortalSkeleton.card(height: 120),
                        SizedBox(height: AppSpacing.md),
                        PortalSkeleton.card(height: 350),
                      ],
                    ),
                  );
                }

                if (state is AssignmentDetailError) {
                  return Center(
                    child: PortalEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Unable to Load Submissions',
                      description: state.message,
                      actionLabel: 'Try Again',
                      onActionPressed: _loadData,
                    ),
                  );
                }

                if (state is AssignmentDetailLoaded) {
                  final submissions = state.allSubmissions;

                  if (submissions.isEmpty) {
                    return Center(
                      child: PortalEmptyState(
                        icon: Icons.assignment_late_outlined,
                        title: 'No Submissions Yet',
                        description:
                            'None of the enrolled students have submitted work for this assignment.',
                        actionLabel: 'Back to Assignments',
                        onActionPressed: () => context.pop(),
                      ),
                    );
                  }

                  final safeIndex = _selectedSubmissionIndex.clamp(0, submissions.length - 1);
                  final currentSub = submissions[safeIndex];

                  return ResponsiveBuilder(
                    builder: (context, sizingInfo) {
                      if (sizingInfo.isDesktop) {
                        return _buildDesktopLayout(
                          context,
                          state,
                          currentSub,
                          gradeState,
                          instructorName,
                        );
                      } else {
                        return _buildMobileLayout(
                          context,
                          state,
                          currentSub,
                          gradeState,
                          instructorName,
                        );
                      }
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AssignmentDetailLoaded state,
    SubmissionEntity currentSub,
    GradingState gradeState,
    String instructorName,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubmissionSelectorBar(state),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Student Submission Preview & Content
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentProfileCard(context, currentSub),
                    const SizedBox(height: AppSpacing.md),
                    _buildSubmissionArtifactsCard(context, currentSub),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Right: Rubric Matrix & Grade Publishing Console
              Expanded(
                flex: 4,
                child: _buildGradingConsole(
                  context,
                  state,
                  currentSub,
                  gradeState,
                  instructorName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AssignmentDetailLoaded state,
    SubmissionEntity currentSub,
    GradingState gradeState,
    String instructorName,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubmissionSelectorBar(state),
          const SizedBox(height: AppSpacing.md),
          _buildStudentProfileCard(context, currentSub),
          const SizedBox(height: AppSpacing.md),
          _buildSubmissionArtifactsCard(context, currentSub),
          const SizedBox(height: AppSpacing.md),
          _buildGradingConsole(
            context,
            state,
            currentSub,
            gradeState,
            instructorName,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSelectorBar(AssignmentDetailLoaded state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subs = state.allSubmissions;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_alt_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Submission ${(_selectedSubmissionIndex + 1)} of ${subs.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.xs,
            children: List.generate(subs.length, (index) {
              final sub = subs[index];
              final isSelected = index == _selectedSubmissionIndex;

              return ChoiceChip(
                label: Text(sub.studentName),
                selected: isSelected,
                avatar: sub.isGraded
                    ? const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success)
                    : const Icon(Icons.pending_rounded, size: 16, color: AppColors.warning),
                onSelected: (val) {
                  if (val) {
                    setState(() => _selectedSubmissionIndex = index);
                    _initGradingForSubmission(sub, state.assignment.rubric);
                  }
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProfileCard(BuildContext context, SubmissionEntity sub) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortalAvatar(
            name: sub.studentName,
            imageUrl: sub.studentAvatar,
            size: PortalAvatarSize.lg,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.studentName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sub.studentEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    PortalBadge(
                      label: sub.courseCode,
                      variant: PortalBadgeVariant.primary,
                    ),
                    if (sub.isGraded)
                      PortalBadge(
                        label: 'Current: ${sub.score?.toInt()}/${sub.maxScore?.toInt()} pts',
                        variant: PortalBadgeVariant.success,
                      )
                    else
                      const PortalBadge(
                        label: 'Needs Evaluation',
                        variant: PortalBadgeVariant.warning,
                        hasDot: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionArtifactsCard(BuildContext context, SubmissionEntity sub) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submitted Deliverables',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (sub.fileName != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.archive_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.fileName!,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Size: ${sub.formattedFileSize} • Submitted ${sub.submittedAt.month}/${sub.submittedAt.day} ${sub.submittedAt.hour}:${sub.submittedAt.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download_rounded, color: AppColors.primary),
                    tooltip: 'Download Solution',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading ${sub.fileName}...')),
                      );
                    },
                  ),
                ],
              ),
            ),
          if (sub.textResponse != null && sub.textResponse!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Student Written Notes / Proof',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: Text(
                sub.textResponse!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradingConsole(
    BuildContext context,
    AssignmentDetailLoaded state,
    SubmissionEntity currentSub,
    GradingState gradeState,
    String instructorName,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final awardedMap = <String, double>{};
    final levelsMap = <String, String?>{};
    final commentsMap = <String, String?>{};
    double totalScore = currentSub.score ?? (currentSub.maxScore ?? 100.0) * 0.9;
    bool isSaving = false;

    if (gradeState is GradingLoaded) {
      awardedMap.addAll(gradeState.criterionScores);
      levelsMap.addAll(gradeState.criterionSelectedLevels);
      commentsMap.addAll(gradeState.criterionComments);
      totalScore = gradeState.totalScore;
      isSaving = gradeState.isPublishing;
    }

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evaluation & Rubric Scoring',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  'Total: ${totalScore.toStringAsFixed(1)} / ${(currentSub.maxScore ?? 100.0).toInt()} pts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Interactive Rubric Matrix
          RubricScoringWidget(
            rubric: state.assignment.rubric,
            awardedScores: awardedMap,
            selectedLevels: levelsMap,
            comments: commentsMap,
            isReadOnly: false,
            onScoreChanged: (criterionId, score, {levelTitle}) {
              context.read<GradingCubit>().updateCriterionScore(
                    criterionId,
                    score,
                    levelTitle: levelTitle,
                  );
              _scoreController.text = (totalScore).toStringAsFixed(1);
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Written constructive feedback
          Text(
            'Instructor Feedback & Recommendations',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            onChanged: (val) {
              context.read<GradingCubit>().updateFeedbackNotes(val);
            },
            decoration: InputDecoration(
              hintText: 'Share constructive notes on code quality, edge cases, and strengths...',
              border: OutlineInputBorder(
                borderRadius: AppSpacing.roundedSm,
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Publish Button
          PortalButton(
            label: 'Publish Grade & Notify Student',
            variant: PortalButtonVariant.primary,
            icon: Icons.check_circle_outline_rounded,
            isLoading: isSaving,
            isFullWidth: true,
            onPressed: () {
              context.read<GradingCubit>().updateFeedbackNotes(_feedbackController.text.trim());
              context.read<GradingCubit>().publishGrade(gradedBy: instructorName);
            },
          ),
        ],
      ),
    );
  }
}
