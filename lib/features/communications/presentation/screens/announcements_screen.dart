import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../cubit/announcements_cubit.dart';
import '../cubit/announcements_state.dart';
import '../widgets/announcement_card.dart';
import '../widgets/create_announcement_dialog.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';
    context.read<AnnouncementsCubit>().loadAnnouncements(studentId: studentId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final isInstructor = authState is Authenticated && authState.user.role.isInstructor;
    final studentId = authState is Authenticated ? authState.user.id : 'demo-student-01';

    return PortalNavigationShell(
      selectedIndex: 5,
      child: ResponsiveLayout(
        mobile: _buildContent(context, isDark, isInstructor, studentId, isMobile: true),
        desktop: _buildContent(context, isDark, isInstructor, studentId, isMobile: false),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    bool isInstructor,
    String studentId, {
    required bool isMobile,
  }) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              _buildHeroHeader(context, isDark, isInstructor, isMobile),
              const SizedBox(height: AppSpacing.lg),

              // Filter Controls
              _buildFilterControls(context, isDark, isMobile),
              const SizedBox(height: AppSpacing.lg),

              // Feed
              BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
                builder: (context, state) {
                  if (state is AnnouncementsLoading) {
                    return Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PortalSkeleton.card(height: 160),
                        ),
                      ),
                    );
                  }

                  if (state is AnnouncementsError) {
                    return Center(
                      child: Column(
                        children: [
                          Text('Failed to load announcements: ${state.message}'),
                          const SizedBox(height: AppSpacing.sm),
                          PortalButton(
                            label: 'Retry',
                            onPressed: _loadData,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AnnouncementsLoaded) {
                    final items = state.filteredAnnouncements;

                    if (items.isEmpty) {
                      return PortalEmptyState(
                        title: 'No Announcements Found',
                        description: 'No announcements match your selected course or priority filters.',
                        actionLabel: isInstructor ? 'Post Announcement' : 'Refresh',
                        onActionPressed: isInstructor
                            ? () => _openCreateDialog(context)
                            : _loadData,
                      );
                    }

                    return Column(
                      children: items.map((announcement) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AnnouncementCard(
                            announcement: announcement,
                            currentUserId: studentId,
                            onAcknowledge: () {
                              context.read<AnnouncementsCubit>().markAsRead(
                                    announcementId: announcement.id,
                                    studentId: studentId,
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isDark, bool isInstructor, bool isMobile) {
    return PortalCard(
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary).withAlpha(25),
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Icon(
                        Icons.campaign_rounded,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Campus broadcasts, course schedule revisions, midterm notices, and urgent faculty alerts.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isInstructor) ...[
            const SizedBox(width: AppSpacing.md),
            PortalButton(
              label: 'Post Announcement',
              icon: Icons.add_rounded,
              size: isMobile ? PortalButtonSize.sm : PortalButtonSize.md,
              onPressed: () => _openCreateDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context, bool isDark, bool isMobile) {
    return BlocBuilder<AnnouncementsCubit, AnnouncementsState>(
      builder: (context, state) {
        final currentCourse = state is AnnouncementsLoaded ? state.selectedCourseId : 'all';
        final currentPriority = state is AnnouncementsLoaded ? state.selectedPriority : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            PortalTextField(
              controller: _searchController,
              isSearch: true,
              hintText: 'Search announcements by keyword, course, or tag...',
              onChanged: (val) => context.read<AnnouncementsCubit>().setSearchQuery(val),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Course filter dropdown & Priority Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Course selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentCourse,
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Courses & Campus')),
                        DropdownMenuItem(value: 'cs101', child: Text('CS101')),
                        DropdownMenuItem(value: 'cs201', child: Text('CS201')),
                        DropdownMenuItem(value: 'math301', child: Text('MATH301')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          context.read<AnnouncementsCubit>().filterByCourse(val);
                        }
                      },
                    ),
                  ),
                ),

                // Priority chips
                _buildPriorityChip(context, isDark, label: 'All Priorities', priority: null, isSelected: currentPriority == null),
                _buildPriorityChip(context, isDark, label: 'Urgent', priority: AnnouncementPriority.urgent, isSelected: currentPriority == AnnouncementPriority.urgent),
                _buildPriorityChip(context, isDark, label: 'Academic', priority: AnnouncementPriority.academic, isSelected: currentPriority == AnnouncementPriority.academic),
                _buildPriorityChip(context, isDark, label: 'Exam Notice', priority: AnnouncementPriority.examNotice, isSelected: currentPriority == AnnouncementPriority.examNotice),
                _buildPriorityChip(context, isDark, label: 'General', priority: AnnouncementPriority.general, isSelected: currentPriority == AnnouncementPriority.general),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityChip(
    BuildContext context,
    bool isDark, {
    required String label,
    required AnnouncementPriority? priority,
    required bool isSelected,
  }) {
    final activeBg = isDark ? AppColors.primaryLight : AppColors.primary;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        context.read<AnnouncementsCubit>().filterByPriority(priority);
      },
      selectedColor: activeBg,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedSm,
        side: BorderSide(
          color: isSelected
              ? activeBg
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
    );
  }

  void _openCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AnnouncementsCubit>(),
        child: const CreateAnnouncementDialog(),
      ),
    );
  }
}
