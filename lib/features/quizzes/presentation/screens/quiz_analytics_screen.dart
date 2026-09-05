import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/quiz_analytics_cubit.dart';
import '../cubit/quiz_analytics_state.dart';

class QuizAnalyticsScreen extends StatefulWidget {
  final String quizId;

  const QuizAnalyticsScreen({super.key, required this.quizId});

  @override
  State<QuizAnalyticsScreen> createState() => _QuizAnalyticsScreenState();
}

class _QuizAnalyticsScreenState extends State<QuizAnalyticsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizAnalyticsCubit>().loadAnalytics(widget.quizId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _simulateCsvExport(BuildContext context, QuizAnalyticsLoaded state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${state.allAttempts.length} submissions for "${state.quiz.title}" to CSV.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Assessment Analytics & Roster'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<QuizAnalyticsCubit, QuizAnalyticsState>(
        builder: (context, state) {
          if (state is QuizAnalyticsLoading || state is QuizAnalyticsInitial) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  PortalSkeleton.card(height: 100),
                  SizedBox(height: AppSpacing.md),
                  PortalSkeleton.card(height: 250),
                ],
              ),
            );
          }

          if (state is QuizAnalyticsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message),
                  const SizedBox(height: AppSpacing.md),
                  PortalButton(
                    label: 'Retry',
                    onPressed: () => context.read<QuizAnalyticsCubit>().loadAnalytics(widget.quizId),
                  ),
                ],
              ),
            );
          }

          if (state is QuizAnalyticsLoaded) {
            final quiz = state.quiz;
            final stats = state.stats;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      PortalCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      PortalBadge(
                                        label: quiz.courseCode,
                                        variant: PortalBadgeVariant.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        quiz.courseTitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    quiz.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${quiz.questionsCount} Questions • ${quiz.totalPoints} Points • Pass Mark: ${quiz.passingPercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PortalButton(
                              label: 'Export CSV',
                              icon: Icons.download_outlined,
                              variant: PortalButtonVariant.secondary,
                              size: PortalButtonSize.sm,
                              onPressed: () => _simulateCsvExport(context, state),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 4 KPI Cards Grid
                      ResponsiveLayout(
                        mobile: Column(
                          children: [
                            _buildKpiCard('Total Submissions', '${stats.totalSubmissions}', Icons.people_outline, isDark),
                            const SizedBox(height: AppSpacing.sm),
                            _buildKpiCard('Average Score', '${stats.averageScore} Pts', Icons.insights, isDark),
                            const SizedBox(height: AppSpacing.sm),
                            _buildKpiCard('Pass Rate', '${stats.passRatePercentage}%', Icons.check_circle_outline, isDark),
                            const SizedBox(height: AppSpacing.sm),
                            _buildKpiCard('Highest / Lowest', '${stats.highestScore} / ${stats.lowestScore}', Icons.swap_vert, isDark),
                          ],
                        ),
                        desktop: Row(
                          children: [
                            Expanded(child: _buildKpiCard('Submissions', '${stats.totalSubmissions}', Icons.people_outline, isDark)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _buildKpiCard('Class Average', '${stats.averageScore} Pts', Icons.insights, isDark)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _buildKpiCard('Pass Rate', '${stats.passRatePercentage}%', Icons.check_circle_outline, isDark)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _buildKpiCard('High / Low', '${stats.highestScore} / ${stats.lowestScore}', Icons.swap_vert, isDark)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Student Submissions Roster Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Student Submissions (${state.filteredAttempts.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => context.read<QuizAnalyticsCubit>().filterStudentSearch(val),
                              decoration: InputDecoration(
                                hintText: 'Search student...',
                                prefixIcon: const Icon(Icons.search, size: 18),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Roster Cards List
                      if (state.filteredAttempts.isEmpty) ...[
                        PortalCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                state.searchFilter.isNotEmpty
                                    ? 'No student submissions match "${state.searchFilter}".'
                                    : 'No submissions recorded for this assessment yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        ...state.filteredAttempts.map((attempt) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: PortalCard(
                              child: Row(
                                children: [
                                  PortalAvatar(
                                    imageUrl: attempt.studentAvatar,
                                    name: attempt.studentName,
                                    size: PortalAvatarSize.md,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          attempt.studentName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${attempt.studentId} • Taken: ${attempt.timeTakenFormatted}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${attempt.score} / ${attempt.totalPossiblePoints} (${attempt.percentage.toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: attempt.passed ? AppColors.success : AppColors.error,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      PortalBadge(
                                        label: attempt.passed ? 'PASSED' : 'FAILED',
                                        variant: attempt.passed ? PortalBadgeVariant.success : PortalBadgeVariant.error,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, bool isDark) {
    return PortalCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: isDark ? 0.25 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
