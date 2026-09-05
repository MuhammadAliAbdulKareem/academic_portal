import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
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
import '../../../instructor_dashboard/presentation/widgets/metric_card.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../cubit/enrollment_cubit.dart';
import '../cubit/student_dashboard_cubit.dart';
import '../cubit/student_dashboard_state.dart';
import '../widgets/enrolled_course_card.dart';
import '../widgets/student_deadline_card.dart';
import '../widgets/student_schedule_card.dart';

/// Comprehensive command center for students with academic metrics, schedule, and courses.
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    context.read<StudentDashboardCubit>().loadDashboard(studentId);
    context.read<EnrollmentCubit>().loadEnrollments(studentId);
  }

  Future<void> _handleRefresh() async {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    await context.read<StudentDashboardCubit>().refreshDashboard(studentId);
    await context.read<EnrollmentCubit>().loadEnrollments(studentId);
  }

  void _confirmDropCourse(BuildContext context, EnrollmentEntity enrollment) {
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Drop Course Offering'),
        content: Text(
          'Are you sure you want to drop ${enrollment.courseCode}: ${enrollment.courseTitle}? You will release your seat in this section.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Drop Course', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        final authState = context.read<AuthCubit>().state;
        final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';

        context.read<EnrollmentCubit>().drop(
              studentId: studentId,
              courseId: enrollment.courseId,
            ).then((_) {
          _handleRefresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dropped ${enrollment.courseCode} successfully.'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.displayName : 'Alex Mercer';

    return PortalNavigationShell(
      selectedIndex: 1,
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Banner
              _buildHeaderBanner(context, userName, isDark),
              const SizedBox(height: AppSpacing.lg),

              // 2. Metrics & Live State
              BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
                builder: (context, state) {
                  if (state is StudentDashboardLoading || state is StudentDashboardInitial) {
                    return _buildLoadingState();
                  }

                  if (state is StudentDashboardError) {
                    return PortalCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 48, color: AppColors.error),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Unable to load academic dashboard',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            PortalButton(
                              label: 'Retry Connection',
                              onPressed: _handleRefresh,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final loaded = state as StudentDashboardLoaded;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Metrics Grid
                      _buildMetricGrid(context, loaded.stats),
                      const SizedBox(height: AppSpacing.xl),

                      // Today's Timetable Section
                      _buildTodayScheduleSection(context, loaded.todaySchedule, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Enrolled Courses Grid
                      _buildEnrolledCoursesSection(context, loaded.enrolledCourses, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Deadlines and Submissions
                      _buildDeadlinesSection(context, loaded.upcomingDeadlines, isDark),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, String userName, bool isDark) {
    return PortalCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ResponsiveBuilder(
        builder: (context, sizing) {
          final isMobile = sizing.isMobile;

          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              Row(
                mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.darkCardGradient
                          : AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Welcome back, $userName!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const PortalBadge(
                              label: 'Fall 2026',
                              variant: PortalBadgeVariant.category,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'B.S. Computer Science • Good Standing (Dean\'s List)',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              PortalButton(
                label: 'Browse Catalog',
                icon: Icons.search_rounded,
                variant: PortalButtonVariant.primary,
                onPressed: () => context.go(RouteConstants.courses),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricGrid(BuildContext context, StudentDashboardStats stats) {
    return ResponsiveBuilder(
      builder: (context, sizing) {
        int columns = 4;
        if (sizing.isMobile) {
          columns = 1;
        } else if (sizing.isTablet) {
          columns = 2;
        }

        final cards = [
          MetricCard(
            title: 'Cumulative GPA',
            value: stats.gpa.toStringAsFixed(2),
            icon: Icons.stars_rounded,
            color: AppColors.primary,
            trendBadge: '+0.12 this term',
            subtitle: stats.academicStanding,
          ),
          MetricCard(
            title: 'Enrolled Credits',
            value: '${stats.enrolledCredits} / ${stats.maxCredits} hrs',
            icon: Icons.menu_book_rounded,
            color: AppColors.secondary,
            subtitle: '${stats.activeCoursesCount} Active Courses',
          ),
          MetricCard(
            title: 'Assignments Due',
            value: '${stats.pendingAssignmentsCount} Pending',
            icon: Icons.assignment_outlined,
            color: AppColors.warning,
            subtitle: 'Keep up the great pace!',
          ),
          MetricCard(
            title: 'Attendance Standing',
            value: '${stats.attendanceRate}%',
            icon: Icons.verified_user_outlined,
            color: AppColors.accentTeal,
            trendBadge: 'Excellent',
            subtitle: 'Top 5% in department',
          ),
        ];

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: sizing.isMobile ? 2.3 : 1.35,
          children: cards,
        );
      },
    );
  }

  Widget _buildTodayScheduleSection(
    BuildContext context,
    List<StudentScheduleItem> schedule,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today\'s Class Schedule (${schedule.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (schedule.isEmpty)
          PortalCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'No classes scheduled for today. Enjoy your study time!',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return StudentScheduleCard(item: schedule[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEnrolledCoursesSection(
    BuildContext context,
    List<EnrollmentEntity> courses,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.school_rounded,
                    size: 20, color: AppColors.secondary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'My Enrolled Courses (${courses.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.go(RouteConstants.courses),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Courses'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (courses.isEmpty)
          PortalEmptyState(
            title: 'No Registered Courses',
            description:
                'You haven\'t enrolled in any courses for the Fall 2026 term yet. Explore the course catalog to begin.',
            buttonLabel: 'Browse Academic Catalog',
            onButtonPressed: () => context.go(RouteConstants.courses),
          )
        else
          ResponsiveBuilder(
            builder: (context, sizing) {
              int columns = 3;
              if (sizing.isMobile) {
                columns = 1;
              } else if (sizing.isTablet) {
                columns = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: sizing.isMobile ? 1.05 : 0.88,
                ),
                itemBuilder: (context, index) {
                  final enr = courses[index];
                  return EnrolledCourseCard(
                    enrollment: enr,
                    onViewDetails: () => context.go('/courses/${enr.courseId}'),
                    onDrop: () => _confirmDropCourse(context, enr),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildDeadlinesSection(
    BuildContext context,
    List<StudentDeadlineItem> deadlines,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist_rounded,
                size: 20, color: AppColors.accentTeal),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Upcoming Deadlines & Submissions (${deadlines.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (deadlines.isEmpty)
          PortalCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'All assignments submitted! No pending deadlines.',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deadlines.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = deadlines[index];
              return StudentDeadlineCard(
                item: item,
                onSubmit: () {
                  final authState = context.read<AuthCubit>().state;
                  final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';

                  context.read<StudentDashboardCubit>().submitAssignment(
                        studentId: studentId,
                        deadlineId: item.id,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Submitted "${item.title}" successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: PortalSkeleton(height: 120)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: PortalSkeleton(height: 120)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const PortalSkeleton(height: 180),
        const SizedBox(height: AppSpacing.md),
        const PortalSkeleton(height: 240),
      ],
    );
  }
}
