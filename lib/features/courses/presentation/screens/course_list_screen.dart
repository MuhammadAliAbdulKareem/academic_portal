import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/course_card.dart';

/// Full catalog screen showcasing search, department filters, and responsive course cards.
class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _departments = [
    'All',
    'Computer Science',
    'Software Engineering',
    'Mathematics',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().loadCourses();
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
      selectedIndex: 3,
      onDestinationSelected: (index) {
        if (index == 0) {
          context.go(RouteConstants.root);
        } else if (index == 1) {
          context.go(RouteConstants.instructorDashboard);
        } else if (index == 2) {
          context.go(RouteConstants.designSystem);
        }
      },
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<CoursesCubit>().refresh(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Create Button
                      _buildHeader(context, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Search & Department Filters
                      _buildSearchAndFilters(context, state, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Course Grid or Empty/Loading state
                      if (state is CoursesLoading || state is CoursesInitial)
                        _buildLoadingGrid(context)
                      else if (state is CoursesError)
                        Center(
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
                                label: 'Retry Loading',
                                onPressed: () =>
                                    context.read<CoursesCubit>().refresh(),
                              ),
                            ],
                          ),
                        )
                      else if (state is CoursesLoaded)
                        _buildCourseGrid(context, state),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final isInstructor =
        authState is Authenticated && authState.user.role.isInstructor;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.isMobile;

        final titleColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Course Catalog',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Explore semester curriculum, course objectives, and class section schedules.',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 14,
              ),
            ),
          ],
        );

        final createButton = PortalButton(
          label: '+ Create New Course',
          variant: PortalButtonVariant.primary,
          icon: Icons.add_circle_outline_rounded,
          onPressed: () {
            if (isInstructor) {
              context.go(RouteConstants.courseCreate);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please sign in as an Instructor to create courses.'),
                  duration: Duration(seconds: 2),
                ),
              );
              context.go(RouteConstants.login);
            }
          },
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleColumn,
              const SizedBox(height: AppSpacing.md),
              createButton,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: titleColumn),
            const SizedBox(width: AppSpacing.md),
            createButton,
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    CoursesState state,
    bool isDark,
  ) {
    final selectedDept =
        state is CoursesLoaded ? state.selectedDepartment : 'All';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        PortalTextField(
          controller: _searchController,
          hintText: 'Search by course code, title, or department...',
          isSearch: true,
          onChanged: (val) => context.read<CoursesCubit>().search(val),
        ),
        const SizedBox(height: AppSpacing.md),

        // Department filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _departments.map((dept) {
              final isSelected = dept == selectedDept;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(dept),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: Colors.white,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.lightSurfaceAlt,
                  onSelected: (_) {
                    context.read<CoursesCubit>().filterByDepartment(dept);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseGrid(BuildContext context, CoursesLoaded loaded) {
    if (loaded.courses.isEmpty) {
      return PortalEmptyState(
        title: 'No Courses Found',
        description:
            'No academic courses matched your search or department filter.',
        actionLabel: 'Reset Filters',
        onActionPressed: () {
          _searchController.clear();
          context.read<CoursesCubit>().loadCourses();
        },
      );
    }

    return ResponsiveBuilder(
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
                  child: CourseCard(
                    course: course,
                    onTap: () {
                      context.go('/courses/${course.id}');
                    },
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return ResponsiveBuilder(
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
              children: List.generate(6, (index) {
                return SizedBox(
                  width: cardWidth,
                  child: const PortalSkeleton.card(height: 280),
                );
              }),
            );
          },
        );
      },
    );
  }
}
