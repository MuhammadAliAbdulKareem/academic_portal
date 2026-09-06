import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/assignment_entity.dart';
import '../cubit/assignment_list_cubit.dart';
import '../cubit/assignment_list_state.dart';
import '../widgets/assignment_card.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedCourse = 'All';

  final List<String> _courseFilters = ['All', 'CS101', 'CS201', 'MATH301'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    final isStudent = authState is Authenticated && authState.user.role == UserRole.student;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';

    if (isStudent) {
      context.read<AssignmentListCubit>().loadAssignmentsForStudent(studentId);
    } else {
      context.read<AssignmentListCubit>().loadAssignmentsForCourse('demo-course-01');
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final tabIndex = _tabController.index;
      final cubit = context.read<AssignmentListCubit>();
      final authState = context.read<AuthCubit>().state;
      final isStudent = authState is Authenticated && authState.user.role == UserRole.student;

      if (isStudent) {
        if (tabIndex == 0) cubit.filterByStatus('All');
        if (tabIndex == 1) cubit.filterByStatus('Open');
        if (tabIndex == 2) cubit.filterByStatus('Closed');
      } else {
        if (tabIndex == 0) cubit.filterByStatus('All');
        if (tabIndex == 1) cubit.filterByStatus('Open');
        if (tabIndex == 2) cubit.filterByStatus('Closed');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _openCreateAssignmentDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final pointsController = TextEditingController(text: '100');
    final weightController = TextEditingController(text: '15');
    String selectedCourse = 'CS101';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    final assignmentListCubit = context.read<AssignmentListCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final authState = context.read<AuthCubit>().state;

    showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return AlertDialog(
              title: const Text('Create New Assignment'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Dropdown
                      Text('Course Offering', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCourse,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: ['CS101', 'CS201', 'MATH301'].map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedCourse = val);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Title
                      Text('Assignment Title', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Problem Set 3: Graph Traversal',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Description
                      Text('Instructions & Specifications', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Describe requirements, input/output, and deliverables...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Points & Weight
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Points', style: theme.textTheme.labelMedium),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: pointsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weight (%)', style: theme.textTheme.labelMedium),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Due Date Picker Button
                      Text('Due Date', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                23,
                                59,
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                            borderRadius: AppSpacing.roundedSm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedDate.month}/${selectedDate.day}/${selectedDate.year} at 11:59 PM',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.of(dialogCtx).pop(true);
                  },
                  child: const Text('Create Assignment'),
                ),
              ],
            );
          },
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        final instructorName =
            authState is Authenticated ? authState.user.displayName : 'Dr. Robert Vance';
        final instructorId =
            authState is Authenticated ? authState.user.id : 'demo-instructor-01';

        final newAssignment = AssignmentEntity(
          id: 'asg-custom-${DateTime.now().millisecondsSinceEpoch}',
          courseId: selectedCourse == 'CS101'
              ? 'demo-course-01'
              : (selectedCourse == 'CS201' ? 'demo-course-02' : 'demo-course-03'),
          courseCode: selectedCourse,
          courseTitle: selectedCourse == 'CS101'
              ? 'Data Structures & Algorithms'
              : (selectedCourse == 'CS201'
                  ? 'Web Application Architectures'
                  : 'Advanced Linear Algebra'),
          instructorId: instructorId,
          instructorName: instructorName,
          title: titleController.text.trim(),
          description: descController.text.trim().isNotEmpty
              ? descController.text.trim()
              : 'Complete all requirements detailed in syllabus specifications.',
          dueDate: selectedDate,
          totalPoints: double.tryParse(pointsController.text) ?? 100.0,
          weightPercentage: double.tryParse(weightController.text) ?? 15.0,
          submissionType: SubmissionType.both,
          rubric: const [
            AssignmentRubricItem(
              id: 'rub-c1',
              title: 'Correctness & Execution',
              description: 'Meets functional specifications and passes test cases.',
              maxPoints: 50.0,
            ),
            AssignmentRubricItem(
              id: 'rub-c2',
              title: 'Documentation & Architecture',
              description: 'Follows clean code principles and provides documentation.',
              maxPoints: 50.0,
            ),
          ],
        );

        assignmentListCubit.createAssignment(newAssignment);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Created ${newAssignment.title} successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authState = context.watch<AuthCubit>().state;
    final isInstructor = authState is Authenticated && authState.user.role == UserRole.instructor;

    return PortalNavigationShell(
      selectedIndex: 2, // Assignments tab
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: CustomScrollView(
            slivers: [
              // Header & Action Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title, Role Badge, and Action Buttons
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Assignments & Grading',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              PortalBadge(
                                label: isInstructor ? 'Instructor Console' : 'Student Portal',
                                variant: isInstructor
                                    ? PortalBadgeVariant.instructor
                                    : PortalBadgeVariant.student,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isInstructor) ...[
                                PortalButton(
                                  label: 'Course Gradebook',
                                  variant: PortalButtonVariant.outline,
                                  size: PortalButtonSize.sm,
                                  icon: Icons.table_chart_rounded,
                                  onPressed: () {
                                    context.push('/courses/demo-course-01/gradebook');
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                PortalButton(
                                  label: 'New Assignment',
                                  variant: PortalButtonVariant.primary,
                                  size: PortalButtonSize.sm,
                                  icon: Icons.add_rounded,
                                  onPressed: () => _openCreateAssignmentDialog(context),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isInstructor
                          ? 'Publish coursework, review student submission queues, and grade with rubrics.'
                          : 'Track assignment deadlines, review rubrics, submit deliverables, and inspect grade feedback.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Search bar & Course filter chips
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                context.read<AssignmentListCubit>().searchAssignments(val);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search by assignment title, code, or keyword...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          context.read<AssignmentListCubit>().searchAssignments('');
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppSpacing.roundedMd,
                                  borderSide: BorderSide(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Filter chips row
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: _courseFilters.map((course) {
                          final isSelected = _selectedCourse == course;
                          return ChoiceChip(
                            label: Text(course),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCourse = course);
                                context.read<AssignmentListCubit>().filterByCourse(
                                      course == 'All' ? null : course,
                                    );
                              }
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Tabs: All, Open/Pending, Closed/Graded
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          const Tab(text: 'All Assignments'),
                          Tab(text: isInstructor ? 'Active / Open' : 'Pending Submission'),
                          Tab(text: isInstructor ? 'Closed / Graded' : 'Completed & Graded'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content Sliver
              BlocBuilder<AssignmentListCubit, AssignmentListState>(
                builder: (context, state) {
                  if (state is AssignmentListLoading) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md),
                            child: PortalSkeleton.card(height: 140),
                          ),
                          childCount: 3,
                        ),
                      ),
                    );
                  }

                  if (state is AssignmentListError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: PortalEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to Load Assignments',
                          description: state.message,
                          actionLabel: 'Try Again',
                          onActionPressed: _loadData,
                        ),
                      ),
                    );
                  }

                  if (state is AssignmentListLoaded) {
                    final items = state.filteredAssignments;

                    if (items.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: PortalEmptyState(
                            icon: Icons.assignment_turned_in_outlined,
                            title: 'No Assignments Found',
                            description: state.searchQuery.isNotEmpty
                                ? 'No assignments match "${state.searchQuery}". Try clearing filters.'
                                : 'There are no assignments in this category right now.',
                            actionLabel: state.searchQuery.isNotEmpty ? 'Clear Search' : null,
                            onActionPressed: () {
                              _searchController.clear();
                              context.read<AssignmentListCubit>().searchAssignments('');
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final assignment = items[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: AssignmentCard(
                                assignment: assignment,
                                isInstructor: isInstructor,
                                onTap: () {
                                  context.push('/assignments/${assignment.id}');
                                },
                                onAction: () {
                                  if (isInstructor) {
                                    context.push('/assignments/${assignment.id}/grade');
                                  } else {
                                    context.push('/assignments/${assignment.id}');
                                  }
                                },
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
