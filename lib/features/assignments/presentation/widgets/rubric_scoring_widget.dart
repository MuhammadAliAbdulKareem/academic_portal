import 'package:flutter/material.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/assignment_entity.dart';

class RubricScoringWidget extends StatelessWidget {
  final List<AssignmentRubricItem> rubric;
  final Map<String, double> awardedScores;
  final Map<String, String?> selectedLevels;
  final Map<String, String?> comments;
  final bool isReadOnly;
  final void Function(String criterionId, double score, {String? levelTitle})? onScoreChanged;

  const RubricScoringWidget({
    super.key,
    required this.rubric,
    required this.awardedScores,
    this.selectedLevels = const {},
    this.comments = const {},
    this.isReadOnly = false,
    this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (rubric.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
          borderRadius: AppSpacing.roundedMd,
        ),
        child: Text(
          'No rubric criteria defined for this assignment.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rubric Criteria (${rubric.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${_calculateTotalAwarded().toStringAsFixed(1)} / ${_calculateTotalMax().toStringAsFixed(1)} pts',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rubric.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final item = rubric[index];
            final awarded = awardedScores[item.id] ?? 0.0;
            final selectedLvl = selectedLevels[item.id];
            final comment = comments[item.id];

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Criterion Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PortalBadge(
                        label: '${awarded.toStringAsFixed(1)} / ${item.maxPoints.toInt()} pts',
                        variant: awarded >= item.maxPoints * 0.85
                            ? PortalBadgeVariant.success
                            : PortalBadgeVariant.primary,
                      ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  // Rubric Levels Grid / Tiers
                  if (item.levels.isNotEmpty)
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: item.levels.map((lvl) {
                        final isSelected = selectedLvl == lvl.title ||
                            (selectedLvl == null && (awarded - lvl.points).abs() < 0.1);

                        return InkWell(
                          onTap: isReadOnly
                              ? null
                              : () => onScoreChanged?.call(
                                    item.id,
                                    lvl.points,
                                    levelTitle: lvl.title,
                                  ),
                          borderRadius: AppSpacing.roundedSm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : (isDark
                                      ? AppColors.darkSurfaceAlt
                                      : AppColors.lightSurfaceAlt),
                              borderRadius: AppSpacing.roundedSm,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      lvl.title,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary),
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${lvl.points.toInt()} pts)',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (lvl.description.isNotEmpty)
                                  Text(
                                    lvl.description,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  // Optional Comment Display
                  if (comment != null && comment.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.comment_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              comment,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  double _calculateTotalAwarded() {
    return awardedScores.values.fold<double>(0.0, (acc, s) => acc + s);
  }

  double _calculateTotalMax() {
    return rubric.fold<double>(0.0, (acc, r) => acc + r.maxPoints);
  }
}
