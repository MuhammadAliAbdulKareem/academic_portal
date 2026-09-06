import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/quiz_list_cubit.dart';
import '../cubit/quiz_list_state.dart';
import '../widgets/quiz_card.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      String? studentId;
      if (authState is Authenticated && authState.user.role == UserRole.student) {
        studentId = authState.user.id;
      }
      context.read<QuizListCubit>().loadQuizzes(studentId: studentId);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final cubit = context.read<QuizListCubit>();
    switch (_tabController.index) {
      case 0:
        cubit.setFilterStatus(QuizFilterStatus.all);
        break;
      case 1:
        cubit.setFilterStatus(QuizFilterStatus.active);
        break;
      case 2:
        cubit.setFilterStatus(QuizFilterStatus.completed);
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final isInstructor = authState is Authenticated &&
        authState.user.role == UserRole.instructor;

    return PortalNavigationShell(
      selectedIndex: 4,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<QuizListCubit>().refresh(),
            child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header Sliver
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + "Create Quiz" Action for Faculty
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quizzes & Exams',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  isInstructor
                                      ? 'Author assessments, manage question banks, and review grade statistics.'
                                      : 'Prepare for upcoming assessments, take timed exams, and review feedback.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isInstructor) ...[
                            const SizedBox(width: AppSpacing.md),
                            PortalButton(
                              label: 'Create Quiz',
                              icon: Icons.add,
                              variant: PortalButtonVariant.primary,
                              onPressed: () => context.push(RouteConstants.quizBuilder),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Search bar + Filter Tabs
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => context.read<QuizListCubit>().searchQuizzes(val),
                        decoration: InputDecoration(
                          hintText: 'Search quizzes by title, course, or topic...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<QuizListCubit>().searchQuizzes('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Filter Tabs
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryLight,
                        unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        indicatorColor: AppColors.primaryLight,
                        tabs: const [
                          Tab(text: 'All Quizzes'),
                          Tab(text: 'Active & Upcoming'),
                          Tab(text: 'Past Due / Closed'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Quizzes Grid / List Content
              BlocBuilder<QuizListCubit, QuizListState>(
                builder: (context, state) {
                  if (state is QuizListLoading || state is QuizListInitial) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

                  if (state is QuizListError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: PortalEmptyState(
                          title: 'Error loading quizzes',
                          description: state.message,
                          icon: Icons.error_outline,
                          actionLabel: 'Retry',
                          onActionPressed: () => context.read<QuizListCubit>().refresh(),
                        ),
                      ),
                    );
                  }

                  if (state is QuizListLoaded) {
                    if (state.filteredQuizzes.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: PortalEmptyState(
                            title: 'No quizzes found',
                            description: state.searchQuery.isNotEmpty
                                ? 'No quizzes match "${state.searchQuery}". Try a different search.'
                                : 'No quizzes available under this filter category.',
                            icon: Icons.quiz_outlined,
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      sliver: context.isMobile
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final quiz = state.filteredQuizzes[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: QuizCard(
                                      quiz: quiz,
                                      isInstructor: isInstructor,
                                      onTap: () => context.push('/quizzes/${quiz.id}'),
                                      onTakeQuiz: () => context.push('/quizzes/${quiz.id}/take'),
                                      onAnalytics: () => context.push('/quizzes/${quiz.id}/analytics'),
                                    ),
                                  );
                                },
                                childCount: state.filteredQuizzes.length,
                              ),
                            )
                          : SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.isDesktop ? 3 : 2,
                                childAspectRatio: 1.25,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final quiz = state.filteredQuizzes[index];
                                  return QuizCard(
                                    quiz: quiz,
                                    isInstructor: isInstructor,
                                    onTap: () => context.push('/quizzes/${quiz.id}'),
                                    onTakeQuiz: () => context.push('/quizzes/${quiz.id}/take'),
                                    onAnalytics: () => context.push('/quizzes/${quiz.id}/analytics'),
                                  );
                                },
                                childCount: state.filteredQuizzes.length,
                              ),
                            ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    ),
  );
}
}
