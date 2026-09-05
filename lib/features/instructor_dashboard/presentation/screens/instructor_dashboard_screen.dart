import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/instructor_dashboard_cubit.dart';
import '../cubit/instructor_dashboard_state.dart';
import '../widgets/course_overview_card.dart';
import '../widgets/metric_card.dart';

/// Comprehensive instructor command center displaying metrics, course rosters,
/// grading queues, and recent student activities.
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() =>
      _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final instructorId = authState is Authenticated ? authState.user.id : 'demo-instructor-1';
    context.read<InstructorDashboardCubit>().loadDashboard(instructorId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) {
          context.go(RouteConstants.designSystem);
        }
      },
      child: BlocBuilder<InstructorDashboardCubit, InstructorDashboardState>(
        builder: (context, state) {
          if (state is InstructorDashboardLoading ||
              state is InstructorDashboardInitial) {
            return _buildLoadingSkeleton(context);
          }

          if (state is InstructorDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  PortalButton(
                    label: 'Retry',
                    onPressed: () {
                      final authState = context.read<AuthCubit>().state;
                      final id = authState is Authenticated ? authState.user.id : 'demo-instructor-1';
                      context.read<InstructorDashboardCubit>().loadDashboard(id);
                    },
                  ),
                ],
              ),
            );
          }

          final loaded = state as InstructorDashboardLoaded;

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthCubit>().state;
              final id = authState is Authenticated ? authState.user.id : 'demo-instructor-1';
              await context.read<InstructorDashboardCubit>().refreshDashboard(id);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHorizontalPadding.horizontal / 2,
                vertical: AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Greeting & Header Banner
                      _buildHeaderBanner(context, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Metric Stats Grid
                      _buildMetricGrid(context, loaded),
                      const SizedBox(height: AppSpacing.xl),

                      // Courses Overview Section
                      _buildCoursesSection(context, loaded),
                      const SizedBox(height: AppSpacing.xl),

                      // Activities & Deadlines Split View
                      _buildSplitFeedSection(context, loaded, isDark),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated
        ? authState.user.displayName
        : 'Dr. Sarah Connor';

    return PortalCard(
      gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          final isMobile = sizingInfo.isMobile;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PortalBadge(
                    label: 'INSTRUCTOR PORTAL',
                    variant: PortalBadgeVariant.instructor,
                    icon: Icons.psychology_outlined,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppSpacing.roundedFull,
                    ),
                    child: const Text(
                      'Fall Semester 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Welcome back, $userName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You have 18 pending assignment submissions requiring your review across 3 active courses.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          );

          final actionButton = PortalButton(
            label: '+ Create New Course',
            variant: PortalButtonVariant.secondary,
            size: PortalButtonSize.md,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Course Creation module is scheduled for Feature 5!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: AppSpacing.lg),
                actionButton,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: content),
              const SizedBox(width: AppSpacing.lg),
              actionButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricGrid(
      BuildContext context, InstructorDashboardLoaded loaded) {
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final crossAxisCount = sizingInfo.isDesktop
            ? 4
            : (sizingInfo.isTablet ? 2 : 1);

        final items = [
          MetricCard(
            title: 'Active Courses',
            value: '${loaded.stats.activeCourses}',
            icon: Icons.menu_book_rounded,
            color: AppColors.primaryLight,
            subtitle: 'All sections in progress',
          ),
          MetricCard(
            title: 'Enrolled Students',
            value: '${loaded.stats.totalStudents}',
            icon: Icons.groups_rounded,
            color: AppColors.accentTeal,
            trendBadge: '+12% term',
          ),
          MetricCard(
            title: 'Pending Grading',
            value: '${loaded.stats.pendingGrading}',
            icon: Icons.rate_review_outlined,
            color: AppColors.accentAmber,
            subtitle: 'Assignments & Quizzes',
          ),
          MetricCard(
            title: 'Average Attendance',
            value: '${loaded.stats.attendanceRate}%',
            icon: Icons.fact_check_outlined,
            color: AppColors.success,
            trendBadge: 'Optimal',
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth -
                    ((crossAxisCount - 1) * AppSpacing.md)) /
                crossAxisCount;

            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: items.map((card) {
                return SizedBox(
                  width: cardWidth,
                  child: card,
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildCoursesSection(
      BuildContext context, InstructorDashboardLoaded loaded) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Assigned Courses (${loaded.courses.length})',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All Courses',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ResponsiveBuilder(
          builder: (context, sizingInfo) {
            final crossAxisCount = sizingInfo.isDesktop
                ? 3
                : (sizingInfo.isTablet ? 2 : 1);

            return LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth -
                        ((crossAxisCount - 1) * AppSpacing.md)) /
                    crossAxisCount;

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: loaded.courses.map((course) {
                    return SizedBox(
                      width: cardWidth,
                      child: CourseOverviewCard(
                        course: course,
                        onManageCourse: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Managing ${course.code}: ${course.title}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSplitFeedSection(
    BuildContext context,
    InstructorDashboardLoaded loaded,
    bool isDark,
  ) {
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isDesktop = sizingInfo.isDesktop;

        final activitiesCard = PortalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 20, color: AppColors.info),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Recent Student Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  PortalBadge(
                    label: 'LIVE STREAM',
                    variant: PortalBadgeVariant.info,
                    hasDot: true,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              ...loaded.activities.map((act) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.lightSurfaceAlt,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          act.type == 'submission'
                              ? Icons.upload_file_rounded
                              : (act.type == 'question'
                                  ? Icons.chat_bubble_outline_rounded
                                  : Icons.person_add_outlined),
                          size: 16,
                          color: act.type == 'submission'
                              ? AppColors.success
                              : (act.type == 'question'
                                  ? AppColors.accentAmber
                                  : AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: act.studentName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' (${act.courseCode}): ',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(text: act.activityDescription),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        final deadlinesCard = PortalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_outlined,
                      size: 20, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Grading Queue & Deadlines',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              ...loaded.deadlines.map((dl) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              dl.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PortalBadge(
                            label: dl.courseCode,
                            variant: PortalBadgeVariant.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Submissions: ${dl.submittedCount} / ${dl.totalExpected}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            '${(dl.completionRatio * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: AppSpacing.roundedFull,
                        child: LinearProgressIndicator(
                          value: dl.completionRatio,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.lightSurfaceAlt,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: activitiesCard),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: deadlinesCard),
            ],
          );
        }

        return Column(
          children: [
            activitiesCard,
            const SizedBox(height: AppSpacing.lg),
            deadlinesCard,
          ],
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PortalSkeleton.card(height: 140),
          SizedBox(height: AppSpacing.lg),
          PortalSkeleton.card(height: 100),
          SizedBox(height: AppSpacing.lg),
          PortalSkeleton.card(height: 200),
        ],
      ),
    );
  }
}
