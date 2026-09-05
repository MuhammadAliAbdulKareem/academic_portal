import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum PortalBadgeVariant {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  neutral,
  instructor,
  student,
}

/// Compact indicator tag for status, roles, and course metadata.
class PortalBadge extends StatelessWidget {
  final String label;
  final PortalBadgeVariant variant;
  final IconData? icon;
  final bool hasDot;

  const PortalBadge({
    super.key,
    required this.label,
    this.variant = PortalBadgeVariant.primary,
    this.icon,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color baseColor;
    switch (variant) {
      case PortalBadgeVariant.primary:
        baseColor = isDark ? AppColors.primaryLight : AppColors.primary;
      case PortalBadgeVariant.secondary:
        baseColor = AppColors.secondary;
      case PortalBadgeVariant.success:
        baseColor = AppColors.success;
      case PortalBadgeVariant.warning:
        baseColor = AppColors.warning;
      case PortalBadgeVariant.error:
        baseColor = AppColors.error;
      case PortalBadgeVariant.info:
        baseColor = AppColors.info;
      case PortalBadgeVariant.neutral:
        baseColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary;
      case PortalBadgeVariant.instructor:
        baseColor = const Color(0xFF8B5CF6); // Royal Purple
      case PortalBadgeVariant.student:
        baseColor = AppColors.accentTeal;
    }

    final backgroundColor = baseColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(
          color: baseColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: baseColor),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: baseColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
