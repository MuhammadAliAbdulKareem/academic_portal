import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/quiz_detail_cubit.dart';
import '../cubit/quiz_detail_state.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      String? studentId;
      if (authState is Authenticated && authState.user.role == UserRole.student) {
        studentId = authState.user.id;
      }
      context.read<QuizDetailCubit>().loadQuizDetail(widget.quizId, studentId: studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final isInstructor = authState is Authenticated &&
        authState.user.role == UserRole.instructor;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Quiz Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<QuizDetailCubit, QuizDetailState>(
        builder: (context, state) {
          if (state is QuizDetailLoading || state is QuizDetailInitial) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  PortalSkeleton.card(height: 120),
                  SizedBox(height: AppSpacing.md),
                  PortalSkeleton.card(height: 200),
                ],
              ),
            );
          }

          if (state is QuizDetailError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: AppSpacing.md),
                  PortalButton(
                    label: 'Retry',
                    onPressed: () {
                      final sId = authState is Authenticated ? authState.user.id : null;
                      context.read<QuizDetailCubit>().loadQuizDetail(widget.quizId, studentId: sId);
                    },
                  ),
                ],
              ),
            );
          }

          if (state is QuizDetailLoaded) {
            final quiz = state.quiz;
            final now = DateTime.now();
            final isPast = now.isAfter(quiz.dueDate);
            final isOpen = quiz.isPublished && !isPast && now.isAfter(quiz.availableFrom);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      PortalCard(
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
                                Expanded(
                                  child: Text(
                                    quiz.courseTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                                if (isOpen)
                                  const PortalBadge(
                                    label: 'Open for Attempt',
                                    variant: PortalBadgeVariant.success,
                                  )
                                else if (isPast)
                                  const PortalBadge(
                                    label: 'Past Due',
                                    variant: PortalBadgeVariant.error,
                                  )
                                else
                                  const PortalBadge(
                                    label: 'Upcoming',
                                    variant: PortalBadgeVariant.warning,
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            Text(
                              quiz.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            Text(
                              quiz.description,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Exam Guidelines & Metrics Grid
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildParam(
                                    icon: Icons.timer_outlined,
                                    label: 'Time Limit',
                                    value: quiz.timeLimitFormatted,
                                    isDark: isDark,
                                  ),
                                  _buildParam(
                                    icon: Icons.quiz_outlined,
                                    label: 'Questions',
                                    value: '${quiz.questionsCount}',
                                    isDark: isDark,
                                  ),
                                  _buildParam(
                                    icon: Icons.military_tech_outlined,
                                    label: 'Total Points',
                                    value: '${quiz.totalPoints} Pts',
                                    isDark: isDark,
                                  ),
                                  _buildParam(
                                    icon: Icons.check_circle_outline,
                                    label: 'Passing Mark',
                                    value: '${quiz.passingPercentage.toStringAsFixed(0)}%',
                                    isDark: isDark,
                                  ),
                                  _buildParam(
                                    icon: Icons.repeat,
                                    label: 'Max Attempts',
                                    value: '${quiz.maxAttempts}',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Instructions Box
                      PortalCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Examination Instructions & Policies',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildBullet(
                              'Once started, the countdown timer will continue running until the time expires or you submit.',
                              isDark,
                            ),
                            _buildBullet(
                              'If time runs out, your active selections will be automatically submitted for evaluation.',
                              isDark,
                            ),
                            _buildBullet(
                              'You can flag questions to review them quickly before submitting.',
                              isDark,
                            ),
                            _buildBullet(
                              'You have ${state.attemptsRemaining} of ${quiz.maxAttempts} attempt(s) remaining.',
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Past Attempts Section (For Students)
                      if (!isInstructor && state.studentAttempts.isNotEmpty) ...[
                        PortalCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Previous Attempts (${state.studentAttempts.length})',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ...state.studentAttempts.map((attempt) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: attempt.passed
                                          ? AppColors.success.withValues(alpha: 0.5)
                                          : AppColors.error.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        attempt.passed ? Icons.check_circle : Icons.cancel,
                                        color: attempt.passed ? AppColors.success : AppColors.error,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Score: ${attempt.score} / ${attempt.totalPossiblePoints} (${attempt.percentage.toStringAsFixed(1)}%)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                              ),
                                            ),
                                            Text(
                                              'Time taken: ${attempt.timeTakenFormatted}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PortalBadge(
                                        label: attempt.passed ? 'PASSED' : 'FAILED',
                                        variant: attempt.passed ? PortalBadgeVariant.success : PortalBadgeVariant.error,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // CTA Button: Start Quiz / Retake
                      if (isInstructor)
                        PortalButton(
                          label: 'View Class Analytics & Roster',
                          icon: Icons.insights,
                          variant: PortalButtonVariant.primary,
                          size: PortalButtonSize.lg,
                          onPressed: () => context.push('/quizzes/${quiz.id}/analytics'),
                        )
                      else if (state.canTakeQuiz)
                        PortalButton(
                          label: state.studentAttempts.isEmpty ? 'Start Examination' : 'Retake Examination',
                          icon: Icons.play_arrow_rounded,
                          variant: PortalButtonVariant.primary,
                          size: PortalButtonSize.lg,
                          onPressed: () => context.push('/quizzes/${quiz.id}/take'),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                state.attemptsRemaining <= 0
                                    ? 'No attempts remaining (${quiz.maxAttempts}/${quiz.maxAttempts} used)'
                                    : 'This quiz is not currently open for submission.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildParam({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryLight),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
