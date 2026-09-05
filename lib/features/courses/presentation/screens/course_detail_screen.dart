import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
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
import '../../../student_portal/presentation/cubit/enrollment_cubit.dart';
import '../../../student_portal/presentation/cubit/enrollment_state.dart';
import '../../domain/entities/course_entity.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';

/// Detailed course screen rendering syllabus timeline, schedule, and section rosters.
class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<CoursesCubit>().loadCourseDetails(widget.courseId);

    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    context.read<EnrollmentCubit>().loadEnrollments(studentId);
  }

  void _enrollCourse(BuildContext context, CourseEntity course) {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';

    context.read<EnrollmentCubit>().enroll(
          studentId: studentId,
          course: course,
        ).then((_) {
      final enrollState = context.read<EnrollmentCubit>().state;
      if (enrollState is EnrollmentLoaded && enrollState.isActionSuccess) {
        // Refresh details to reflect updated seat count
        context.read<CoursesCubit>().loadCourseDetails(course.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enrollState.message ?? 'Enrolled in ${course.code} successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (enrollState is EnrollmentError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enrollState.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  void _confirmDropCourse(BuildContext context, CourseEntity course) {
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Drop Course Offering'),
        content: Text(
          'Are you sure you want to drop ${course.code}: ${course.title}? You will relinquish your enrolled seat.',
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
              courseId: course.id,
            ).then((_) {
          context.read<CoursesCubit>().loadCourseDetails(course.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dropped ${course.code} successfully.'),
                backgroundColor: AppColors.secondary,
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 3,
      onDestinationSelected: (index) {
        if (index == 0) {
          context.go(RouteConstants.root);
        } else if (index == 1) {
          context.go(RouteConstants.instructorDashboard);
        } else if (index == 2) {
          context.go(RouteConstants.designSystem);
        } else if (index == 3) {
          context.go(RouteConstants.courses);
        }
      },
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading || state is CoursesInitial) {
            return _buildLoading(context);
          }

          if (state is CoursesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  PortalButton(
                    label: 'Back to Catalog',
                    onPressed: () => context.go(RouteConstants.courses),
                  ),
                ],
              ),
            );
          }

          CourseEntity? course;
          if (state is CoursesLoaded) {
            course = state.selectedCourse ??
                state.courses.where((c) => c.id == widget.courseId).firstOrNull;
          }

          if (course == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.accentAmber),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Course Not Found',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: AppSpacing.md),
                  PortalButton(
                    label: 'Return to Courses',
                    onPressed: () => context.go(RouteConstants.courses),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
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
                    // Back Link
                    TextButton.icon(
                      onPressed: () => context.go(RouteConstants.courses),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Back to Course Catalog'),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Hero Banner Card
                    _buildHeroBanner(context, course, isDark),
                    const SizedBox(height: AppSpacing.xl),

                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: AppSpacing.roundedMd,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryLight,
                        unselectedLabelColor: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                        indicatorColor: AppColors.primaryLight,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.info_outline_rounded, size: 18),
                            text: 'Overview & Logistics',
                          ),
                          Tab(
                            icon: Icon(Icons.menu_book_rounded, size: 18),
                            text: 'Syllabus & Modules',
                          ),
                          Tab(
                            icon: Icon(Icons.groups_outlined, size: 18),
                            text: 'Roster & Capacity',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Tab View Contents
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(context, course, isDark),
                          _buildSyllabusTab(context, course, isDark),
                          _buildRosterTab(context, course, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    CourseEntity course,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final isInstructor =
        authState is Authenticated && authState.user.role.isInstructor;

    return PortalCard(
      gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PortalBadge(
                    label: course.code,
                    variant: PortalBadgeVariant.primary,
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
                    child: Text(
                      course.department,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    child: Text(
                      '${course.credits} Credits',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              PortalBadge(
                label: course.term.toUpperCase(),
                variant: PortalBadgeVariant.info,
                hasDot: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            course.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              PortalAvatar(
                name: course.instructorName,
                size: PortalAvatarSize.sm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.instructorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Course Instructor • ${course.department}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isInstructor)
                PortalButton(
                  label: 'Manage Course',
                  variant: PortalButtonVariant.secondary,
                  size: PortalButtonSize.sm,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Managing course ${course.code}...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                )
              else
                BlocBuilder<EnrollmentCubit, EnrollmentState>(
                  builder: (context, enrollState) {
                    final isEnrolled = enrollState is EnrollmentLoaded &&
                        enrollState.isEnrolled(course.id);

                    if (isEnrolled) {
                      return PortalButton(
                        label: 'Enrolled (Drop)',
                        variant: PortalButtonVariant.destructive,
                        size: PortalButtonSize.sm,
                        icon: Icons.check_circle_rounded,
                        onPressed: () => _confirmDropCourse(context, course),
                      );
                    }

                    return PortalButton(
                      label: course.isFull ? 'Course Full' : 'Enroll in Course',
                      variant: PortalButtonVariant.secondary,
                      size: PortalButtonSize.sm,
                      icon: Icons.add_circle_outline_rounded,
                      disabled: course.isFull,
                      onPressed: course.isFull
                          ? null
                          : () => _enrollCourse(context, course),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    CourseEntity course,
    bool isDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About this Course',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(height: AppSpacing.lg),
                Text(
                  course.description.isNotEmpty
                      ? course.description
                      : 'No detailed description available for this course.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ResponsiveBuilder(
            builder: (context, sizingInfo) {
              final isDesktop = sizingInfo.isDesktop;

              final scheduleCard = PortalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 18, color: AppColors.primaryLight),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Schedule & Location',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.md),
                    Text(
                      'Time: ${course.schedule}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room: ${course.room}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Term: ${course.term}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              );

              final capacityCard = PortalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_outlined,
                            size: 18, color: AppColors.accentTeal),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Enrollment Status',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enrolled:'),
                        Text(
                          '${course.enrolledCount} / ${course.maxCapacity}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: AppSpacing.roundedFull,
                      child: LinearProgressIndicator(
                        value: course.enrollmentRatio,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.lightSurfaceAlt,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryLight),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${course.maxCapacity - course.enrolledCount} open seats remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              );

              if (isDesktop) {
                return Row(
                  children: [
                    Expanded(child: scheduleCard),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: capacityCard),
                  ],
                );
              }

              return Column(
                children: [
                  scheduleCard,
                  const SizedBox(height: AppSpacing.md),
                  capacityCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusTab(
    BuildContext context,
    CourseEntity course,
    bool isDark,
  ) {
    if (course.syllabus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories_outlined,
                size: 48, color: AppColors.darkTextMuted),
            const SizedBox(height: AppSpacing.md),
            const Text('No Syllabus Modules Published',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'The instructor has not uploaded weekly course curriculum units yet.',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: course.syllabus.length,
      itemBuilder: (context, index) {
        final item = course.syllabus[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: PortalCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Text(
                    'WEEK ${item.weekNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRosterTab(
    BuildContext context,
    CourseEntity course,
    bool isDark,
  ) {
    return PortalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section Roster & Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRosterStat(
                  'Enrolled', '${course.enrolledCount}', AppColors.primaryLight),
              _buildRosterStat(
                  'Capacity', '${course.maxCapacity}', AppColors.accentTeal),
              _buildRosterStat(
                  'Available',
                  '${course.maxCapacity - course.enrolledCount}',
                  AppColors.success),
              _buildRosterStat(
                  'Fill Rate',
                  '${(course.enrollmentRatio * 100).toStringAsFixed(1)}%',
                  AppColors.accentAmber),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: PortalButton(
              label: 'Download Section Roster (CSV)',
              icon: Icons.download_rounded,
              variant: PortalButtonVariant.outline,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exporting student roster data...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortalSkeleton.card(height: 180),
          SizedBox(height: AppSpacing.lg),
          PortalSkeleton.card(height: 320),
        ],
      ),
    );
  }
}
