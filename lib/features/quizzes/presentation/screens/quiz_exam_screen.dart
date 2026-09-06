import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/quiz_exam_session_cubit.dart';
import '../cubit/quiz_exam_session_state.dart';
import '../widgets/exam_timer_widget.dart';
import '../widgets/question_palette_widget.dart';
import '../widgets/question_view_card.dart';
import '../widgets/quiz_result_card.dart';

class QuizExamScreen extends StatefulWidget {
  final String quizId;

  const QuizExamScreen({super.key, required this.quizId});

  @override
  State<QuizExamScreen> createState() => _QuizExamScreenState();
}

class _QuizExamScreenState extends State<QuizExamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      String studentId = 'student_demo';
      String studentName = 'Demo Student';
      String? avatar;

      if (authState is Authenticated) {
        studentId = authState.user.id;
        studentName = authState.user.displayName;
        avatar = authState.user.photoUrl;
      }

      context.read<QuizExamSessionCubit>().startSession(
            quizId: widget.quizId,
            studentId: studentId,
            studentName: studentName,
            studentAvatar: avatar,
          );
    });
  }

  void _showSubmitConfirmation(BuildContext context, QuizExamSessionActive state) {
    final unanswered = state.totalQuestions - state.answeredCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Text(
            'Submit Examination?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have answered ${state.answeredCount} of ${state.totalQuestions} questions.',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 14,
                ),
              ),
              if (unanswered > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '$unanswered question(s) remain unanswered.',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Once submitted, your answers will be finalized and evaluated.',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Return to Exam'),
            ),
            PortalButton(
              label: 'Confirm & Submit',
              variant: PortalButtonVariant.primary,
              size: PortalButtonSize.sm,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<QuizExamSessionCubit>().submitExam();
              },
            ),
          ],
        );
      },
    );
  }

  void _showExitWarning(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: const Text('Leave Active Examination?'),
          content: const Text(
            'Exiting now will submit your examination with your current answers.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Stay'),
            ),
            PortalButton(
              label: 'Submit & Exit',
              variant: PortalButtonVariant.destructive,
              size: PortalButtonSize.sm,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<QuizExamSessionCubit>().submitExam();
              },
            ),
          ],
        );
      },
    );
  }

  void _openPaletteSheet(BuildContext context, QuizExamSessionActive state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: QuestionPaletteWidget(
            questions: state.questions,
            currentIndex: state.currentQuestionIndex,
            answers: state.answers,
            flaggedIds: state.flaggedQuestionIds,
            onSelectQuestion: (index) {
              Navigator.of(context).pop();
              context.read<QuizExamSessionCubit>().jumpToQuestion(index);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final state = context.read<QuizExamSessionCubit>().state;
        if (state is QuizExamSessionActive) {
          _showExitWarning(context);
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SafeArea(
          child: BlocConsumer<QuizExamSessionCubit, QuizExamSessionState>(
            listener: (context, state) {
              if (state is QuizExamSessionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is QuizExamSessionStarting || state is QuizExamSessionInitial) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Initializing Examination Hall...'),
                    ],
                  ),
                );
              }

              if (state is QuizExamSessionSubmitting) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Submitting and evaluating answers...'),
                    ],
                  ),
                );
              }

              if (state is QuizExamSessionSubmitted) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: QuizResultCard(
                        quiz: state.quiz,
                        attempt: state.attempt,
                        questions: state.questions,
                        onReturn: () => context.go('/quizzes'),
                      ),
                    ),
                  ),
                );
              }

              if (state is QuizExamSessionActive) {
                final cubit = context.read<QuizExamSessionCubit>();
                final q = state.currentQuestion;
                final isFlagged = state.isQuestionFlagged(q.id);
                final currentAnswer = state.answers[q.id];

                return Column(
                  children: [
                    // Sticky Top Navigation Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        border: Border(
                          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Exit Examination',
                            onPressed: () => _showExitWarning(context),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.quiz.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions} • ${state.answeredCount} answered',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ExamTimerWidget(
                            remainingSeconds: state.remainingSeconds,
                            totalSeconds: state.totalSeconds,
                          ),
                          if (!isDesktop) ...[
                            const SizedBox(width: AppSpacing.xs),
                            IconButton(
                              icon: const Icon(Icons.grid_view_rounded),
                              tooltip: 'Question Palette',
                              onPressed: () => _openPaletteSheet(context, state),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Progress Bar
                    LinearProgressIndicator(
                      value: state.progressPercentage,
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                      minHeight: 3,
                    ),

                    // Main Content: Question Card + (Optional Side Palette on Desktop)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Card Area
                            Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 800),
                                    child: QuestionViewCard(
                                      question: q,
                                      questionNumber: state.currentQuestionIndex + 1,
                                      totalQuestions: state.totalQuestions,
                                      currentAnswer: currentAnswer,
                                      isFlagged: isFlagged,
                                      onAnswerChanged: (ans) => cubit.selectAnswer(q.id, ans),
                                      onToggleFlag: () => cubit.toggleFlagQuestion(q.id),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Desktop Side Palette
                            if (isDesktop) ...[
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                flex: 1,
                                child: PortalCard(
                                  child: QuestionPaletteWidget(
                                    questions: state.questions,
                                    currentIndex: state.currentQuestionIndex,
                                    answers: state.answers,
                                    flaggedIds: state.flaggedQuestionIds,
                                    onSelectQuestion: (index) => cubit.jumpToQuestion(index),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Sticky Bottom Controls Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        border: Border(
                          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Button
                          PortalButton(
                            label: 'Previous',
                            icon: Icons.chevron_left,
                            variant: PortalButtonVariant.secondary,
                            size: PortalButtonSize.md,
                            onPressed: state.isFirstQuestion ? null : () => cubit.previousQuestion(),
                          ),

                          // Center: Flag Toggle
                          PortalButton(
                            label: isFlagged ? 'Flagged' : 'Flag for Review',
                            icon: isFlagged ? Icons.flag : Icons.outlined_flag,
                            variant: isFlagged ? PortalButtonVariant.secondary : PortalButtonVariant.ghost,
                            size: PortalButtonSize.md,
                            onPressed: () => cubit.toggleFlagQuestion(q.id),
                          ),

                          // Right: Next or Submit
                          if (state.isLastQuestion)
                            PortalButton(
                              label: 'Submit Exam',
                              icon: Icons.check_circle_outline,
                              variant: PortalButtonVariant.primary,
                              size: PortalButtonSize.md,
                              onPressed: () => _showSubmitConfirmation(context, state),
                            )
                          else
                            PortalButton(
                              label: 'Next',
                              icon: Icons.chevron_right,
                              variant: PortalButtonVariant.primary,
                              size: PortalButtonSize.md,
                              onPressed: () => cubit.nextQuestion(),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
