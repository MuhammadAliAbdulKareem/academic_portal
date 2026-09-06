import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/course_entity.dart';
import '../cubit/course_form_cubit.dart';
import '../cubit/course_form_state.dart';
import '../cubit/courses_cubit.dart';

/// Interactive multi-section course builder for instructors.
class CourseCreateScreen extends StatefulWidget {
  const CourseCreateScreen({super.key});

  @override
  State<CourseCreateScreen> createState() => _CourseCreateScreenState();
}

class _CourseCreateScreenState extends State<CourseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _roomController = TextEditingController();
  final _capacityController = TextEditingController(text: '45');
  final _creditsController = TextEditingController(text: '3');

  String _selectedDepartment = 'Computer Science';
  String _selectedTerm = 'Fall 2026';

  final List<String> _departmentOptions = [
    'Computer Science',
    'Software Engineering',
    'Mathematics',
    'Data Science',
  ];

  final List<String> _termOptions = [
    'Fall 2026',
    'Spring 2027',
    'Summer 2027',
  ];

  final List<SyllabusItem> _syllabus = [
    const SyllabusItem(
      weekNumber: 1,
      title: 'Course Introduction & Objectives',
      description: 'Overview of syllabus, grading policy, and preliminary concepts.',
    ),
    const SyllabusItem(
      weekNumber: 2,
      title: 'Core Fundamentals & Architecture',
      description: 'Deep dive into foundational theoretical and practical models.',
    ),
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    _roomController.dispose();
    _capacityController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _addSyllabusItem() {
    final nextWeek = _syllabus.length + 1;
    final topicController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Week $nextWeek Module'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PortalTextField(
                controller: topicController,
                label: 'Topic Title',
                hintText: 'e.g., Dynamic Programming & Recursion',
              ),
              const SizedBox(height: AppSpacing.md),
              PortalTextField(
                controller: descController,
                label: 'Topic Description',
                hintText: 'Brief learning outcomes and practical exercises...',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            PortalButton(
              label: 'Add Module',
              size: PortalButtonSize.sm,
              onPressed: () {
                if (topicController.text.trim().isNotEmpty) {
                  setState(() {
                    _syllabus.add(
                      SyllabusItem(
                        weekNumber: nextWeek,
                        title: topicController.text.trim(),
                        description: descController.text.trim(),
                      ),
                    );
                  });
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthCubit>().state;
      final instructorId =
          authState is Authenticated ? authState.user.id : 'demo-inst-01';
      final instructorName =
          authState is Authenticated ? authState.user.displayName : 'Dr. Sarah Jenkins';

      final capacity = int.tryParse(_capacityController.text.trim()) ?? 45;
      final credits = int.tryParse(_creditsController.text.trim()) ?? 3;

      context.read<CourseFormCubit>().submitCourse(
            code: _codeController.text.trim(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            instructorId: instructorId,
            instructorName: instructorName,
            term: _selectedTerm,
            department: _selectedDepartment,
            credits: credits,
            schedule: _scheduleController.text.trim(),
            room: _roomController.text.trim(),
            maxCapacity: capacity,
            syllabus: _syllabus,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 1,
      child: BlocConsumer<CourseFormCubit, CourseFormState>(
        listener: (context, state) {
          if (state is CourseFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Course "${state.course.code}" created successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<CoursesCubit>().refresh();
            context.go('/courses/${state.course.id}');
          } else if (state is CourseFormFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CourseFormSubmitting;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalPadding.horizontal / 2,
              vertical: AppSpacing.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxFormWidth + 200,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back Button & Header
                      _buildHeader(context, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Section 1: Course Identity Card
                      _buildIdentitySection(context, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 2: Schedule & Capacity Card
                      _buildScheduleSection(context, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 3: Syllabus Timeline Card
                      _buildSyllabusSection(context, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => context.go(RouteConstants.courses),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          PortalButton(
                            label: 'Publish Course Offering',
                            variant: PortalButtonVariant.primary,
                            isLoading: isSubmitting,
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: isSubmitting ? null : _onSubmit,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => context.go(RouteConstants.courses),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Back to Course Catalog'),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Create Course Offering',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Define course curriculum, assign section schedules, and publish weekly learning modules.',
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildIdentitySection(BuildContext context, bool isDark) {
    return PortalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 20, color: AppColors.primaryLight),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Course Identity & Academic Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          ResponsiveBuilder(
            builder: (context, sizingInfo) {
              final isMobile = sizingInfo.isMobile;

              final codeField = PortalTextField(
                controller: _codeController,
                label: 'Course Code *',
                hintText: 'e.g., CS-305',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Course code is required';
                  }
                  return null;
                },
              );

              final titleField = PortalTextField(
                controller: _titleController,
                label: 'Course Title *',
                hintText: 'e.g., Advanced Database Systems',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Course title is required';
                  }
                  return null;
                },
              );

              if (isMobile) {
                return Column(
                  children: [
                    codeField,
                    const SizedBox(height: AppSpacing.md),
                    titleField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 180, child: codeField),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: titleField),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Department and Term Selector Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Department *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDepartment,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      items: _departmentOptions.map((dept) {
                        return DropdownMenuItem(value: dept, child: Text(dept));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDepartment = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Term *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTerm,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      items: _termOptions.map((term) {
                        return DropdownMenuItem(value: term, child: Text(term));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTerm = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Description
          PortalTextField(
            controller: _descriptionController,
            label: 'Course Description',
            hintText: 'Comprehensive syllabus overview and learning objectives...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context, bool isDark) {
    return PortalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 20, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Section Schedule & Capacity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PortalTextField(
                  controller: _scheduleController,
                  label: 'Weekly Schedule *',
                  hintText: 'e.g., Mon / Wed • 10:00 AM - 11:30 AM',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Schedule is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PortalTextField(
                  controller: _roomController,
                  label: 'Room / Facility *',
                  hintText: 'e.g., Turing Lab 2',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Room is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PortalTextField(
                  controller: _capacityController,
                  label: 'Max Enrollment Capacity',
                  hintText: 'e.g., 50',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PortalTextField(
                  controller: _creditsController,
                  label: 'Credits',
                  hintText: 'e.g., 3',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusSection(BuildContext context, bool isDark) {
    return PortalCard(
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
                  const Icon(Icons.menu_book_rounded,
                      size: 20, color: AppColors.accentTeal),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Syllabus & Modules (${_syllabus.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              PortalButton(
                label: '+ Add Module',
                variant: PortalButtonVariant.secondary,
                size: PortalButtonSize.sm,
                onPressed: _addSyllabusItem,
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          if (_syllabus.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No syllabus modules added yet. Tap "+ Add Module" to start structuring your course curriculum.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          else
            ...List.generate(_syllabus.length, (index) {
              final item = _syllabus[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.lightSurfaceAlt,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          '${item.weekNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        onPressed: () {
                          setState(() => _syllabus.removeAt(index));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
