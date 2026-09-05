import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../tokens/app_animations.dart';

enum PortalButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

enum PortalButtonSize {
  sm,
  md,
  lg,
}

/// Primary button component for the Academic Portal platform.
class PortalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PortalButtonVariant variant;
  final PortalButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? trailingIcon;

  const PortalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PortalButtonVariant.primary,
    this.size = PortalButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.trailingIcon,
  });

  @override
  State<PortalButton> createState() => _PortalButtonState();
}

class _PortalButtonState extends State<PortalButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final verticalPadding = switch (widget.size) {
      PortalButtonSize.sm => 8.0,
      PortalButtonSize.md => 12.0,
      PortalButtonSize.lg => 16.0,
    };

    final horizontalPadding = switch (widget.size) {
      PortalButtonSize.sm => 14.0,
      PortalButtonSize.md => 20.0,
      PortalButtonSize.lg => 28.0,
    };

    final fontSize = switch (widget.size) {
      PortalButtonSize.sm => 12.0,
      PortalButtonSize.md => 14.0,
      PortalButtonSize.lg => 16.0,
    };

    final iconSize = switch (widget.size) {
      PortalButtonSize.sm => 16.0,
      PortalButtonSize.md => 18.0,
      PortalButtonSize.lg => 20.0,
    };

    // Styling according to variant
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case PortalButtonVariant.primary:
        backgroundColor = _isHovered
            ? (isDark ? AppColors.primaryLight : const Color(0xFF1D4ED8))
            : (isDark ? AppColors.primaryLight : AppColors.primary);
        foregroundColor = Colors.white;
      case PortalButtonVariant.secondary:
        backgroundColor = _isHovered
            ? (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0))
            : (isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt);
        foregroundColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      case PortalButtonVariant.outline:
        backgroundColor = _isHovered
            ? (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.06))
            : Colors.transparent;
        foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        borderSide = BorderSide(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 1.5,
        );
      case PortalButtonVariant.ghost:
        backgroundColor = _isHovered
            ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
            : Colors.transparent;
        foregroundColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      case PortalButtonVariant.destructive:
        backgroundColor = _isHovered ? const Color(0xFFDC2626) : AppColors.error;
        foregroundColor = Colors.white;
    }

    if (!_isEnabled) {
      backgroundColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
      foregroundColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8);
      borderSide = BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: iconSize, color: foregroundColor),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
            letterSpacing: 0.2,
          ),
        ),
        if (widget.trailingIcon != null && !widget.isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.trailingIcon!,
        ],
      ],
    );

    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (_isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isEnabled) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (_isEnabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (_isEnabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (_isEnabled) setState(() => _isPressed = false);
        },
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: AppAnimations.micro,
          curve: AppAnimations.standard,
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            curve: AppAnimations.standard,
            width: widget.isFullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppSpacing.roundedMd,
              border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
