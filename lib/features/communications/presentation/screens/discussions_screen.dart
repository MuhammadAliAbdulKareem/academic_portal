import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/discussion_entity.dart';
import '../cubit/discussions_cubit.dart';
import '../cubit/discussions_state.dart';
import '../widgets/create_discussion_dialog.dart';
import '../widgets/discussion_thread_card.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
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
    context.read<DiscussionsCubit>().loadDiscussions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 6,
      child: ResponsiveLayout(
        mobile: _buildContent(context, isDark, isMobile: true),
        desktop: _buildContent(context, isDark, isMobile: false),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, {required bool isMobile}) {
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
              // Header banner
              _buildHeroHeader(context, isDark, isMobile),
              const SizedBox(height: AppSpacing.lg),

              // Filter row
              _buildFilters(context, isDark, isMobile),
              const SizedBox(height: AppSpacing.lg),

              // Thread List
              BlocBuilder<DiscussionsCubit, DiscussionsState>(
                builder: (context, state) {
                  if (state is DiscussionsLoading) {
                    return Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PortalSkeleton.card(height: 140),
                        ),
                      ),
                    );
                  }

                  if (state is DiscussionsError) {
                    return Center(
                      child: Column(
                        children: [
                          Text('Failed to load discussions: ${state.message}'),
                          const SizedBox(height: AppSpacing.sm),
                          PortalButton(label: 'Retry', onPressed: _loadData),
                        ],
                      ),
                    );
                  }

                  if (state is DiscussionsLoaded) {
                    final items = state.filteredThreads;

                    if (items.isEmpty) {
                      return PortalEmptyState(
                        title: 'No Discussions Found',
                        description: 'No questions or discussion threads match your filter criteria.',
                        actionLabel: 'Ask Question',
                        onActionPressed: () => _openCreateDialog(context),
                      );
                    }

                    return Column(
                      children: items.map((thread) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DiscussionThreadCard(
                            thread: thread,
                            onTap: () => context.go('/discussions/${thread.id}'),
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

  Widget _buildHeroHeader(BuildContext context, bool isDark, bool isMobile) {
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
                        Icons.forum_rounded,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Discussions & Q&A',
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
                  'Engage with professors and peers, ask questions, share code snippets, and review endorsed solutions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          PortalButton(
            label: 'Ask Question',
            icon: Icons.add_comment_rounded,
            size: isMobile ? PortalButtonSize.sm : PortalButtonSize.md,
            onPressed: () => _openCreateDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, bool isDark, bool isMobile) {
    return BlocBuilder<DiscussionsCubit, DiscussionsState>(
      builder: (context, state) {
        final currentCourse = state is DiscussionsLoaded ? state.selectedCourseId : 'all';
        final currentCategory = state is DiscussionsLoaded ? state.selectedCategory : null;
        final onlyUnresolved = state is DiscussionsLoaded ? state.onlyUnresolved : false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortalTextField(
              controller: _searchController,
              isSearch: true,
              hintText: 'Search discussion topics by keyword or code snippet...',
              onChanged: (val) => context.read<DiscussionsCubit>().setSearchQuery(val),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Course Dropdown
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
                        DropdownMenuItem(value: 'all', child: Text('All Courses')),
                        DropdownMenuItem(value: 'cs101', child: Text('CS101')),
                        DropdownMenuItem(value: 'cs201', child: Text('CS201')),
                        DropdownMenuItem(value: 'math301', child: Text('MATH301')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          context.read<DiscussionsCubit>().filterByCourse(val);
                        }
                      },
                    ),
                  ),
                ),

                // Category Chips
                _buildCategoryChip(context, isDark, label: 'All Topics', category: null, isSelected: currentCategory == null),
                _buildCategoryChip(context, isDark, label: 'Homework Help', category: DiscussionCategory.homeworkHelp, isSelected: currentCategory == DiscussionCategory.homeworkHelp),
                _buildCategoryChip(context, isDark, label: 'Exam Prep', category: DiscussionCategory.examPrep, isSelected: currentCategory == DiscussionCategory.examPrep),
                _buildCategoryChip(context, isDark, label: 'Technical Q&A', category: DiscussionCategory.technicalQuestions, isSelected: currentCategory == DiscussionCategory.technicalQuestions),
                _buildCategoryChip(context, isDark, label: 'Project Collab', category: DiscussionCategory.projectCollab, isSelected: currentCategory == DiscussionCategory.projectCollab),

                // Unresolved toggle
                FilterChip(
                  label: Text(
                    'Unresolved Only',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: onlyUnresolved ? FontWeight.w700 : FontWeight.w500,
                      color: onlyUnresolved
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  selected: onlyUnresolved,
                  onSelected: (_) => context.read<DiscussionsCubit>().toggleUnresolvedOnly(),
                  selectedColor: AppColors.warning,
                  checkmarkColor: Colors.white,
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.roundedSm,
                    side: BorderSide(
                      color: onlyUnresolved
                          ? AppColors.warning
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    bool isDark, {
    required String label,
    required DiscussionCategory? category,
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
      onSelected: (_) => context.read<DiscussionsCubit>().filterByCategory(category),
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
        value: context.read<DiscussionsCubit>(),
        child: const CreateDiscussionDialog(),
      ),
    );
  }
}
