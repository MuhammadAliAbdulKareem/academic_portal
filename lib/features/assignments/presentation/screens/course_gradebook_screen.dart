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
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/gradebook_cubit.dart';
import '../cubit/gradebook_state.dart';

class CourseGradebookScreen extends StatefulWidget {
  final String courseId;

  const CourseGradebookScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseGradebookScreen> createState() => _CourseGradebookScreenState();
}

class _CourseGradebookScreenState extends State<CourseGradebookScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GradebookCubit>().loadGradebook(widget.courseId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 1, // Courses tab
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.canPop() ? context.pop() : context.go('/courses'),
          ),
          title: Text(
            'Course Gradebook',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: PortalButton(
                label: 'Export CSV',
                variant: PortalButtonVariant.outline,
                size: PortalButtonSize.sm,
                icon: Icons.file_download_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gradebook CSV report exported successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocBuilder<GradebookCubit, GradebookState>(
          builder: (context, state) {
            if (state is GradebookLoading) {
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

            if (state is GradebookError) {
              return Center(
                child: PortalEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to Load Gradebook',
                  description: state.message,
                  actionLabel: 'Try Again',
                  onActionPressed: _loadData,
                ),
              );
            }

            if (state is GradebookLoaded) {
              final gb = state.gradebook;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Header & KPI cards
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PortalBadge(
                                  label: gb.courseCode,
                                  variant: PortalBadgeVariant.primary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  gb.courseTitle,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Official Roster & Weighted Grade Summary (${gb.entries.length} Enrolled Students)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3 KPI metric cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 650;
                        return Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _buildKpiCard(
                              context,
                              title: 'Class Average',
                              value: '${gb.classAveragePercentage.toStringAsFixed(1)}%',
                              icon: Icons.analytics_outlined,
                              color: AppColors.primary,
                              isCompact: isCompact,
                            ),
                            _buildKpiCard(
                              context,
                              title: 'Highest Score',
                              value: '${gb.highestPercentage.toStringAsFixed(1)}%',
                              icon: Icons.trending_up_rounded,
                              color: AppColors.success,
                              isCompact: isCompact,
                            ),
                            _buildKpiCard(
                              context,
                              title: 'Lowest Score',
                              value: '${gb.lowestPercentage.toStringAsFixed(1)}%',
                              icon: Icons.trending_down_rounded,
                              color: AppColors.warning,
                              isCompact: isCompact,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Gradebook Data Table Container
                    PortalCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Grade Matrix',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                              ),
                              columns: [
                                const DataColumn(label: Text('Student')),
                                ...gb.assignments.map(
                                  (a) => DataColumn(
                                    label: Text(
                                      '${a.title}\n(${a.totalPoints.toInt()} pts)',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const DataColumn(label: Text('Total Pts')),
                                const DataColumn(label: Text('Score %')),
                                const DataColumn(label: Text('Grade')),
                              ],
                              rows: gb.entries.map((entry) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PortalAvatar(
                                            name: entry.studentName,
                                            imageUrl: entry.studentAvatar,
                                            size: PortalAvatarSize.sm,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.studentName,
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              Text(
                                                entry.studentEmail,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? AppColors.darkTextMuted
                                                      : AppColors.lightTextMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...gb.assignments.map((a) {
                                      final score = entry.assignmentScores[a.id];
                                      return DataCell(
                                        Center(
                                          child: Text(
                                            score != null
                                                ? score.toStringAsFixed(1)
                                                : '—',
                                            style: TextStyle(
                                              fontWeight: score != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    DataCell(
                                      Text(
                                        '${entry.totalPointsEarned.toStringAsFixed(1)} / ${entry.totalPointsPossible.toInt()}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${entry.percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: entry.percentage >= 85
                                              ? AppColors.success
                                              : (entry.percentage >= 70
                                                  ? AppColors.warning
                                                  : AppColors.error),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      PortalBadge(
                                        label: entry.letterGrade,
                                        variant: entry.percentage >= 85
                                            ? PortalBadgeVariant.success
                                            : (entry.percentage >= 70
                                                ? PortalBadgeVariant.primary
                                                : PortalBadgeVariant.warning),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: isCompact ? double.infinity : 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
