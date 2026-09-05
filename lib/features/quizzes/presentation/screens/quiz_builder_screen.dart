import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/quiz_entity.dart';
import '../cubit/quiz_builder_cubit.dart';
import '../cubit/quiz_builder_state.dart';
import '../cubit/quiz_list_cubit.dart';

class QuizBuilderScreen extends StatefulWidget {
  const QuizBuilderScreen({super.key});

  @override
  State<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends State<QuizBuilderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<Map<String, String>> _demoCourses = [
    {
      'id': 'course_cs101',
      'code': 'CS101',
      'title': 'Introduction to Computer Science & Algorithms',
    },
    {
      'id': 'course_cs201',
      'code': 'CS201',
      'title': 'Data Structures and Algorithms',
    },
    {
      'id': 'course_math301',
      'code': 'MATH301',
      'title': 'Linear Algebra & Applications',
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<QuizBuilderCubit>().initNewQuiz();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddQuestionDialog(BuildContext context) {
    final promptController = TextEditingController();
    final pointsController = TextEditingController(text: '10');
    final explanationController = TextEditingController();
    QuestionType selectedType = QuestionType.singleChoice;

    final opt1 = TextEditingController(text: 'Option A');
    final opt2 = TextEditingController(text: 'Option B');
    final opt3 = TextEditingController(text: 'Option C');
    final opt4 = TextEditingController(text: 'Option D');
    int singleCorrect = 0;
    bool tfCorrect = true;
    final shortAnswerCorrect = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              title: Text(
                'Add Question to Assessment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Type Dropdown
                      DropdownButtonFormField<QuestionType>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(labelText: 'Question Type'),
                        items: QuestionType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedType = val);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Prompt
                      TextField(
                        controller: promptController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Question Prompt',
                          hintText: 'Enter question problem or statement...',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Points
                      TextField(
                        controller: pointsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Points'),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Specific inputs based on type
                      if (selectedType == QuestionType.singleChoice) ...[
                        Text(
                          'Answer Choices (Select radio for correct answer):',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ...List.generate(4, (i) {
                          final controllers = [opt1, opt2, opt3, opt4];
                          return Row(
                            children: [
                              InkWell(
                                onTap: () => setDialogState(() => singleCorrect = i),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    singleCorrect == i ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: singleCorrect == i
                                        ? AppColors.primaryLight
                                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                    size: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: controllers[i],
                                  decoration: InputDecoration(hintText: 'Option ${String.fromCharCode(65 + i)}'),
                                ),
                              ),
                            ],
                          );
                        }),
                      ] else if (selectedType == QuestionType.trueFalse) ...[
                        Text(
                          'Correct Answer:',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('True'),
                              selected: tfCorrect == true,
                              onSelected: (val) => setDialogState(() => tfCorrect = true),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            ChoiceChip(
                              label: const Text('False'),
                              selected: tfCorrect == false,
                              onSelected: (val) => setDialogState(() => tfCorrect = false),
                            ),
                          ],
                        ),
                      ] else if (selectedType == QuestionType.shortAnswer) ...[
                        TextField(
                          controller: shortAnswerCorrect,
                          decoration: const InputDecoration(
                            labelText: 'Expected Answer (Keyword)',
                            hintText: 'e.g. Divide and Conquer',
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),

                      // Explanation
                      TextField(
                        controller: explanationController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Explanation (Optional feedback)',
                          hintText: 'Why this answer is correct...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                PortalButton(
                  label: 'Add Question',
                  variant: PortalButtonVariant.primary,
                  size: PortalButtonSize.sm,
                  onPressed: () {
                    final prompt = promptController.text.trim();
                    if (prompt.isEmpty) return;

                    final pts = int.tryParse(pointsController.text.trim()) ?? 10;
                    List<String> options = [];
                    dynamic correctAns;
                    List<int> correctIndices = [];

                    if (selectedType == QuestionType.singleChoice) {
                      options = [opt1.text, opt2.text, opt3.text, opt4.text];
                      correctAns = singleCorrect;
                      correctIndices = [singleCorrect];
                    } else if (selectedType == QuestionType.trueFalse) {
                      options = ['True', 'False'];
                      correctAns = tfCorrect;
                      correctIndices = [tfCorrect ? 0 : 1];
                    } else if (selectedType == QuestionType.shortAnswer) {
                      correctAns = shortAnswerCorrect.text.trim();
                    }

                    final newQ = QuizQuestionEntity(
                      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
                      quizId: '',
                      prompt: prompt,
                      type: selectedType,
                      options: options,
                      correctAnswer: correctAns,
                      correctOptionIndices: correctIndices,
                      explanation: explanationController.text.trim(),
                      points: pts,
                    );

                    context.read<QuizBuilderCubit>().addQuestion(newQ);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Create New Assessment'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<QuizBuilderCubit, QuizBuilderState>(
        listener: (context, state) {
          if (state is QuizBuilderSaved) {
            context.read<QuizListCubit>().refresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quiz "${state.createdQuiz.title}" created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is QuizBuilderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! QuizBuilderEditing) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<QuizBuilderCubit>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quiz Settings Card
                    PortalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'General Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Course Selector Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: state.courseId,
                            decoration: const InputDecoration(labelText: 'Target Course'),
                            items: _demoCourses.map((c) {
                              return DropdownMenuItem(
                                value: c['id'],
                                child: Text('${c['code']} - ${c['title']}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final selected = _demoCourses.firstWhere((c) => c['id'] == val);
                                cubit.updateCourseInfo(
                                  courseId: selected['id']!,
                                  courseCode: selected['code']!,
                                  courseTitle: selected['title']!,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Title
                          TextField(
                            controller: _titleController,
                            onChanged: (val) => cubit.updateBasicDetails(title: val),
                            decoration: const InputDecoration(
                              labelText: 'Quiz / Exam Title',
                              hintText: 'e.g. Midterm 1: Algorithm Analysis',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Description
                          TextField(
                            controller: _descriptionController,
                            maxLines: 2,
                            onChanged: (val) => cubit.updateBasicDetails(description: val),
                            decoration: const InputDecoration(
                              labelText: 'Instructions / Description',
                              hintText: 'Brief summary or rules for students...',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Parameters Row: Time Limit & Passing Rate & Max Attempts
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: state.timeLimitMinutes.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Time Limit (Mins)'),
                                  onChanged: (val) {
                                    final n = int.tryParse(val);
                                    if (n != null) cubit.updateBasicDetails(timeLimitMinutes: n);
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: TextFormField(
                                  initialValue: state.passingPercentage.toStringAsFixed(0),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Passing Mark (%)'),
                                  onChanged: (val) {
                                    final n = double.tryParse(val);
                                    if (n != null) cubit.updateBasicDetails(passingPercentage: n);
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: TextFormField(
                                  initialValue: state.maxAttempts.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Max Attempts'),
                                  onChanged: (val) {
                                    final n = int.tryParse(val);
                                    if (n != null) cubit.updateBasicDetails(maxAttempts: n);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Switches Row: Shuffle, Allow Review
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile(
                                  title: const Text('Shuffle Questions'),
                                  value: state.shuffleQuestions,
                                  onChanged: (val) => cubit.updateBasicDetails(shuffleQuestions: val),
                                ),
                              ),
                              Expanded(
                                child: SwitchListTile(
                                  title: const Text('Allow Review'),
                                  value: state.allowReview,
                                  onChanged: (val) => cubit.updateBasicDetails(allowReview: val),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Questions Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Question Bank (${state.questions.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            PortalBadge(
                              label: 'Total: ${state.computedTotalPoints} Points',
                              variant: PortalBadgeVariant.primary,
                            ),
                          ],
                        ),
                        PortalButton(
                          label: 'Add Question',
                          icon: Icons.add,
                          variant: PortalButtonVariant.secondary,
                          size: PortalButtonSize.sm,
                          onPressed: () => _showAddQuestionDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Questions List
                    if (state.questions.isEmpty) ...[
                      PortalCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 48,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'No questions added yet.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Click "Add Question" above to populate the assessment bank.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      ...List.generate(state.questions.length, (index) {
                        final q = state.questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: PortalCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          PortalBadge(
                                            label: q.type.displayName,
                                            variant: PortalBadgeVariant.secondary,
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          PortalBadge(
                                            label: '${q.points} Pts',
                                            variant: PortalBadgeVariant.primary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        q.prompt,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  tooltip: 'Delete Question',
                                  onPressed: () => cubit.removeQuestion(q.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: AppSpacing.xl),

                    // Submit & Save Button
                    PortalButton(
                      label: state.isSaving ? 'Publishing Assessment...' : 'Publish Assessment',
                      icon: Icons.cloud_upload_outlined,
                      variant: PortalButtonVariant.primary,
                      size: PortalButtonSize.lg,
                      onPressed: state.isSaving ? null : () => cubit.saveQuiz(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
