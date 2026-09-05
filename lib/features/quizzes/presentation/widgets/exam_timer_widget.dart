import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ExamTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const ExamTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (totalSeconds <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.all_inclusive,
              size: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Untimed',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final fraction = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final isCritical = remainingSeconds <= 60;
    final isWarning = remainingSeconds <= 300 && !isCritical;

    final Color timerColor;
    final Color bgColor;

    if (isCritical) {
      timerColor = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1);
    } else if (isWarning) {
      timerColor = AppColors.warning;
      bgColor = AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1);
    } else {
      timerColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1);
    }

    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    final formatted = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: timerColor.withValues(alpha: 0.5),
          width: isCritical ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              backgroundColor: timerColor.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatted,
            style: TextStyle(
              color: timerColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
