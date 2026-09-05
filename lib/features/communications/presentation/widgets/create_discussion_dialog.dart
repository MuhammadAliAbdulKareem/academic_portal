import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/discussion_entity.dart';
import '../cubit/discussions_cubit.dart';

class CreateDiscussionDialog extends StatefulWidget {
  const CreateDiscussionDialog({super.key});

  @override
  State<CreateDiscussionDialog> createState() => _CreateDiscussionDialogState();
}

class _CreateDiscussionDialogState extends State<CreateDiscussionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCourse = 'cs101';
  DiscussionCategory _selectedCategory = DiscussionCategory.homeworkHelp;
  bool _isSubmitting = false;

  final Map<String, String> _courses = {
    'cs101': 'CS101 - Intro to Computer Science',
    'cs201': 'CS201 - Data Structures & Algorithms',
    'math301': 'MATH301 - Multivariable Calculus',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authState = context.read<AuthCubit>().state;
    final authorId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    final authorName = authState is Authenticated ? authState.user.displayName : 'Alex Mercer';
    final authorRole = authState is Authenticated ? authState.user.role.displayName : 'Student';
    final authorAvatar = authState is Authenticated ? authState.user.photoUrl : null;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    String courseCode = 'CS101';
    String courseTitle = 'Intro to Computer Science';
    if (_selectedCourse == 'cs201') {
      courseCode = 'CS201';
      courseTitle = 'Data Structures & Algorithms';
    } else if (_selectedCourse == 'math301') {
      courseCode = 'MATH301';
      courseTitle = 'Multivariable Calculus';
    }

    final thread = DiscussionThreadEntity(
      id: 'thread-${DateTime.now().millisecondsSinceEpoch}',
      courseId: _selectedCourse,
      courseCode: courseCode,
      courseTitle: courseTitle,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      authorAvatar: authorAvatar,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      isResolved: false,
      repliesCount: 0,
      replies: const [],
      tags: tags,
    );

    await context.read<DiscussionsCubit>().createThread(thread);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.forum_rounded, color: isDark ? AppColors.primaryLight : AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'New Discussion Topic / Question',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Course
                  Text(
                    'Course',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourse,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
                    ),
                    items: _courses.entries.map((e) {
                      return DropdownMenuItem(value: e.key, child: Text(e.value));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCourse = val!),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Category
                  Text(
                    'Topic Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<DiscussionCategory>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
                    ),
                    items: DiscussionCategory.values.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c.displayName));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Title
                  PortalTextField(
                    label: 'Question / Topic Title',
                    controller: _titleController,
                    hintText: 'Be specific (e.g. Stack depth in memoized recursion)',
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Content
                  Text(
                    'Description & Context',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 4,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter content' : null,
                    decoration: InputDecoration(
                      hintText: 'Include what you tried, errors, or code snippets with ```...',
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tags
                  PortalTextField(
                    label: 'Tags (comma separated)',
                    controller: _tagsController,
                    hintText: 'e.g. Recursion, Big-O, Assignment 2',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PortalButton(
                        label: 'Cancel',
                        variant: PortalButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      PortalButton(
                        label: 'Post Discussion',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
