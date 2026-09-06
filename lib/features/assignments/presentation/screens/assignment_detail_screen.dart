import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/assignment_detail_cubit.dart';
import '../cubit/assignment_detail_state.dart';
import '../cubit/submission_cubit.dart';
import '../cubit/submission_state.dart';
import '../widgets/grade_summary_card.dart';
import '../widgets/rubric_scoring_widget.dart';
import '../widgets/submission_item_card.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final TextEditingController _textResponseController = TextEditingController();
  String? _selectedFileName;
  int? _selectedFileSize;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';

    context.read<AssignmentDetailCubit>().loadAssignmentDetails(
          assignmentId: widget.assignmentId,
          studentId: studentId,
        );
  }

  @override
  void dispose() {
    _textResponseController.dispose();
    super.dispose();
  }

  void _simulateFilePick() {
    setState(() {
      _selectedFileName = 'project_solution_${DateTime.now().millisecondsSinceEpoch % 1000}.zip';
      _selectedFileSize = 2457600; // 2.3 MB
    });
  }

  void _submitWork(BuildContext context, AssignmentDetailLoaded state) {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    final studentName = authState is Authenticated ? authState.user.displayName : 'Alex Mercer';
    final studentEmail = authState is Authenticated ? authState.user.email : 'student@academic.edu';

    context.read<SubmissionCubit>().submitWork(
          assignmentId: state.assignment.id,
          assignmentTitle: state.assignment.title,
          courseCode: state.assignment.courseCode,
          studentId: studentId,
          studentName: studentName,
          studentEmail: studentEmail,
          fileName: _selectedFileName,
          fileSizeBytes: _selectedFileSize,
          textResponse: _textResponseController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = context.watch<AuthCubit>().state;
    final isInstructor = authState is Authenticated && authState.user.role == UserRole.instructor;

    return PortalNavigationShell(
      selectedIndex: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/assignments'),
          ),
          title: Text(
            'Assignment Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: BlocConsumer<SubmissionCubit, SubmissionState>(
          listener: (context, subState) {
            if (subState is SubmissionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assignment submitted successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadData();
            } else if (subState is SubmissionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(subState.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, subState) {
            return BlocBuilder<AssignmentDetailCubit, AssignmentDetailState>(
              builder: (context, state) {
                if (state is AssignmentDetailLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        PortalSkeleton.card(height: 180),
                        SizedBox(height: AppSpacing.md),
                        PortalSkeleton.card(height: 300),
                      ],
                    ),
                  );
                }

                if (state is AssignmentDetailError) {
                  return Center(
                    child: PortalEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Assignment Not Found',
                      description: state.message,
                      actionLabel: 'Back to Assignments',
                      onActionPressed: () => context.pop(),
                    ),
                  );
                }

                if (state is AssignmentDetailLoaded) {
                  return ResponsiveBuilder(
                    builder: (context, sizingInfo) {
                      if (sizingInfo.isDesktop) {
                        return _buildDesktopLayout(context, state, isInstructor, subState);
                      } else {
                        return _buildMobileLayout(context, state, isInstructor, subState);
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
    bool isInstructor,
    SubmissionState subState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Specifications, Attachments, Rubric
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, state.assignment),
                const SizedBox(height: AppSpacing.md),
                _buildSpecificationsCard(context, state.assignment),
                const SizedBox(height: AppSpacing.md),
                _buildRubricSection(context, state),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Right Column: Student Submission / Graded Review OR Instructor Queue
          Expanded(
            flex: 2,
            child: isInstructor
                ? _buildInstructorSubmissionsQueue(context, state)
                : _buildStudentSubmissionPanel(context, state, subState),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AssignmentDetailLoaded state,
    bool isInstructor,
    SubmissionState subState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, state.assignment),
          const SizedBox(height: AppSpacing.md),
          if (isInstructor)
            _buildInstructorSubmissionsQueue(context, state)
          else
            _buildStudentSubmissionPanel(context, state, subState),
          const SizedBox(height: AppSpacing.md),
          _buildSpecificationsCard(context, state.assignment),
          const SizedBox(height: AppSpacing.md),
          _buildRubricSection(context, state),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, dynamic assignment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PortalBadge(
                label: assignment.courseCode,
                variant: PortalBadgeVariant.primary,
                icon: Icons.school_outlined,
              ),
              PortalBadge(
                label: assignment.courseTitle,
                variant: PortalBadgeVariant.neutral,
              ),
              PortalBadge(
                label: '${assignment.totalPoints.toInt()} Points',
                variant: PortalBadgeVariant.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            assignment.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Instructor: ${assignment.instructorName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_available_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Due: ${assignment.dueDate.month}/${assignment.dueDate.day}/${assignment.dueDate.year} at 11:59 PM',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'Course Weight: ${assignment.weightPercentage.toInt()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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

  Widget _buildSpecificationsCard(BuildContext context, dynamic assignment) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements & Instructions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            assignment.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.6,
            ),
          ),
          if (assignment.attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Attached Reference Files',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: assignment.attachments.map<Widget>((att) {
                return Chip(
                  avatar: const Icon(Icons.file_download_outlined, size: 16),
                  label: Text(att),
                  backgroundColor:
                      isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  onDeleted: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading $att...')),
                    );
                  },
                  deleteIcon: const Icon(Icons.download_rounded, size: 16),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRubricSection(BuildContext context, AssignmentDetailLoaded state) {
    final studentSub = state.studentSubmission;
    final Map<String, double> awardedMap = {};
    final Map<String, String?> selectedLevels = {};
    final Map<String, String?> comments = {};

    if (studentSub != null && studentSub.rubricScores.isNotEmpty) {
      for (final rs in studentSub.rubricScores) {
        awardedMap[rs.criterionId] = rs.awardedPoints;
        selectedLevels[rs.criterionId] = rs.selectedLevelTitle;
        comments[rs.criterionId] = rs.comments;
      }
    }

    return RubricScoringWidget(
      rubric: state.assignment.rubric,
      awardedScores: awardedMap,
      selectedLevels: selectedLevels,
      comments: comments,
      isReadOnly: true,
    );
  }

  Widget _buildStudentSubmissionPanel(
    BuildContext context,
    AssignmentDetailLoaded state,
    SubmissionState subState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sub = state.studentSubmission;

    if (sub != null && sub.isGraded) {
      return GradeSummaryCard(submission: sub);
    }

    if (sub != null) {
      // Submitted but pending evaluation
      return PortalCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Received',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Submitted on ${sub.submittedAt.month}/${sub.submittedAt.day} at ${sub.submittedAt.hour}:${sub.submittedAt.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const PortalBadge(
                  label: 'Pending Grade',
                  variant: PortalBadgeVariant.warning,
                  hasDot: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (sub.fileName != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${sub.fileName} (${sub.formattedFileSize})',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (sub.textResponse != null && sub.textResponse!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Student Notes:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub.textResponse!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            PortalButton(
              label: 'Resubmit Assignment',
              variant: PortalButtonVariant.outline,
              size: PortalButtonSize.sm,
              icon: Icons.refresh_rounded,
              isFullWidth: true,
              onPressed: () {
                setState(() {
                  _selectedFileName = null;
                  _selectedFileSize = null;
                  _textResponseController.clear();
                });
                context.read<SubmissionCubit>().reset();
              },
            ),
          ],
        ),
      );
    }

    // New submission form
    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Your Solution',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Upload your code bundle or write your answer directly below.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // File upload simulator box
          InkWell(
            onTap: _simulateFilePick,
            borderRadius: AppSpacing.roundedMd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(
                  color: _selectedFileName != null
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFileName != null
                        ? Icons.insert_drive_file_rounded
                        : Icons.cloud_upload_outlined,
                    size: 36,
                    color: _selectedFileName != null ? AppColors.primary : AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _selectedFileName ?? 'Tap to select solution file (.zip, .pdf, .dart)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          _selectedFileName != null ? FontWeight.w700 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedFileSize != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Size: 2.3 MB (Ready for upload)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Text response field
          Text(
            'Additional Notes or Direct Response',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _textResponseController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe implementation details, test commands, or written proofs...',
              border: OutlineInputBorder(
                borderRadius: AppSpacing.roundedSm,
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Submit Action Button
          PortalButton(
            label: 'Submit Deliverables',
            variant: PortalButtonVariant.primary,
            icon: Icons.send_rounded,
            isLoading: subState is SubmissionSubmitting,
            isFullWidth: true,
            onPressed: () => _submitWork(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSubmissionsQueue(
    BuildContext context,
    AssignmentDetailLoaded state,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subs = state.allSubmissions;

    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Submissions (${subs.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PortalButton(
                label: 'Grading Cockpit',
                variant: PortalButtonVariant.primary,
                size: PortalButtonSize.sm,
                icon: Icons.fact_check_rounded,
                onPressed: () {
                  context.push('/assignments/${state.assignment.id}/grade');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (subs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No submissions received yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subs.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final sub = subs[index];
                return SubmissionItemCard(
                  submission: sub,
                  onGrade: () {
                    context.push('/assignments/${state.assignment.id}/grade');
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
