import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/quiz_entity.dart';

class QuestionViewCard extends StatefulWidget {
  final QuizQuestionEntity question;
  final int questionNumber;
  final int totalQuestions;
  final dynamic currentAnswer;
  final bool isFlagged;
  final ValueChanged<dynamic> onAnswerChanged;
  final VoidCallback onToggleFlag;

  const QuestionViewCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.currentAnswer,
    required this.isFlagged,
    required this.onAnswerChanged,
    required this.onToggleFlag,
  });

  @override
  State<QuestionViewCard> createState() => _QuestionViewCardState();
}

class _QuestionViewCardState extends State<QuestionViewCard> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.question.type == QuestionType.shortAnswer && widget.currentAnswer is String
          ? widget.currentAnswer as String
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant QuestionViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _textController.text = widget.question.type == QuestionType.shortAnswer && widget.currentAnswer is String
          ? widget.currentAnswer as String
          : '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question index + Type Badge + Points + Flag Action
          Row(
            children: [
              Text(
                'Question ${widget.questionNumber} of ${widget.totalQuestions}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PortalBadge(
                label: widget.question.type.displayName,
                variant: PortalBadgeVariant.secondary,
              ),
              const Spacer(),
              PortalBadge(
                label: '${widget.question.points} ${widget.question.points == 1 ? 'Pt' : 'Pts'}',
                variant: PortalBadgeVariant.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: Icon(
                  widget.isFlagged ? Icons.flag : Icons.outlined_flag,
                  color: widget.isFlagged
                      ? AppColors.warning
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                tooltip: widget.isFlagged ? 'Remove Flag' : 'Flag for Review',
                onPressed: widget.onToggleFlag,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Question Prompt
          Text(
            widget.question.prompt,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dynamic Answer Options
          _buildAnswerInput(isDark),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(bool isDark) {
    switch (widget.question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice(isDark);
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(isDark);
      case QuestionType.trueFalse:
        return _buildTrueFalse(isDark);
      case QuestionType.shortAnswer:
        return _buildShortAnswer(isDark);
    }
  }

  Widget _buildSingleChoice(bool isDark) {
    final selectedIndex = widget.currentAnswer is int ? widget.currentAnswer as int : null;

    return Column(
      children: List.generate(widget.question.options.length, (index) {
        final option = widget.question.options[index];
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: InkWell(
            onTap: () => widget.onAnswerChanged(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08)
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primaryLight : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryLight
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primaryLight, size: 22)
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMultipleChoice(bool isDark) {
    final selectedIndices = widget.currentAnswer is List
        ? (widget.currentAnswer as List).map((e) => e as int).toSet()
        : <int>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select all that apply:',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(widget.question.options.length, (index) {
          final option = widget.question.options[index];
          final isSelected = selectedIndices.contains(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: () {
                final newSet = Set<int>.from(selectedIndices);
                if (isSelected) {
                  newSet.remove(index);
                } else {
                  newSet.add(index);
                }
                widget.onAnswerChanged(newSet.toList()..sort());
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryLight : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        final newSet = Set<int>.from(selectedIndices);
                        if (val == true) {
                          newSet.add(index);
                        } else {
                          newSet.remove(index);
                        }
                        widget.onAnswerChanged(newSet.toList()..sort());
                      },
                      activeColor: AppColors.primaryLight,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrueFalse(bool isDark) {
    final selectedValue = widget.currentAnswer is bool ? widget.currentAnswer as bool : null;

    return Row(
      children: [
        Expanded(
          child: _buildBinaryOption(
            label: 'True',
            icon: Icons.check_circle_outline,
            isSelected: selectedValue == true,
            isDark: isDark,
            onTap: () => widget.onAnswerChanged(true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildBinaryOption(
            label: 'False',
            icon: Icons.cancel_outlined,
            isSelected: selectedValue == false,
            isDark: isDark,
            onTap: () => widget.onAnswerChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildBinaryOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.primaryLight
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.primaryLight
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortAnswer(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          onChanged: (val) => widget.onAnswerChanged(val.trim()),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Answers are case-insensitive.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
