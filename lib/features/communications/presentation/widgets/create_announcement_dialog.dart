import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../cubit/announcements_cubit.dart';

class CreateAnnouncementDialog extends StatefulWidget {
  const CreateAnnouncementDialog({super.key});

  @override
  State<CreateAnnouncementDialog> createState() => _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends State<CreateAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedCourse = 'all';
  AnnouncementPriority _selectedPriority = AnnouncementPriority.academic;
  bool _isPinned = false;
  bool _isSubmitting = false;

  final Map<String, String> _courses = {
    'all': 'Campus-Wide Broadcast',
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
    final authorId = authState is Authenticated ? authState.user.id : 'inst-01';
    final authorName = authState is Authenticated ? authState.user.displayName : 'Faculty Instructor';
    final authorAvatar = authState is Authenticated ? authState.user.photoUrl : null;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    String courseCode = 'CAMPUS';
    String courseTitle = 'Campus-Wide';
    if (_selectedCourse == 'cs101') {
      courseCode = 'CS101';
      courseTitle = 'Intro to Computer Science';
    } else if (_selectedCourse == 'cs201') {
      courseCode = 'CS201';
      courseTitle = 'Data Structures & Algorithms';
    } else if (_selectedCourse == 'math301') {
      courseCode = 'MATH301';
      courseTitle = 'Multivariable Calculus';
    }

    final announcement = AnnouncementEntity(
      id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
      courseId: _selectedCourse,
      courseCode: courseCode,
      courseTitle: courseTitle,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      authorId: authorId,
      authorName: authorName,
      authorRole: 'Faculty Instructor',
      authorAvatar: authorAvatar,
      priority: _selectedPriority,
      isPinned: _isPinned,
      publishedAt: DateTime.now(),
      tags: tags,
      readByStudentIds: const [],
    );

    await context.read<AnnouncementsCubit>().createAnnouncement(announcement);

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
                      Icon(Icons.campaign_rounded, color: isDark ? AppColors.primaryLight : AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'New Announcement',
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

                  // Target Course
                  Text(
                    'Target Audience / Course',
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

                  // Priority
                  Text(
                    'Priority Level',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<AnnouncementPriority>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
                    ),
                    items: AnnouncementPriority.values.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.displayName));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPriority = val!),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Title
                  PortalTextField(
                    label: 'Announcement Title',
                    controller: _titleController,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Content
                  Text(
                    'Announcement Body',
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
                      hintText: 'Provide details, instructions, or updates...',
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: AppSpacing.roundedSm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tags
                  PortalTextField(
                    label: 'Tags (comma separated)',
                    controller: _tagsController,
                    hintText: 'e.g. Midterms, Venue Change, Room 204',
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Pin to top checkbox
                  CheckboxListTile(
                    value: _isPinned,
                    title: const Text('Pin this announcement to top of feed'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) => setState(() => _isPinned = val ?? false),
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
                        label: 'Publish Announcement',
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
