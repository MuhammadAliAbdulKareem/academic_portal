import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../tokens/app_animations.dart';
import '../tokens/app_shadows.dart';

/// Versatile surface container supporting interactive hover states and gradients.
class PortalCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isHoverable;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  const PortalCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isHoverable = false,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.borderRadius,
  });

  @override
  State<PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<PortalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBackground = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final effectiveRadius = widget.borderRadius ?? AppSpacing.roundedLg;

    final shadows = _isHovered && widget.isHoverable
        ? (isDark ? AppShadows.darkHover : AppShadows.lightHover)
        : (isDark ? AppShadows.darkCard : AppShadows.lightCard);

    final effectiveBorder = _isHovered && widget.isHoverable
        ? (isDark ? AppColors.primaryLight.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.4))
        : (widget.borderColor ?? defaultBorder);

    Widget card = AnimatedContainer(
      duration: AppAnimations.fast,
      curve: AppAnimations.decelerate,
      transform: _isHovered && widget.isHoverable
          ? Matrix4.translationValues(0.0, -2.0, 0.0)
          : Matrix4.identity(),
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: widget.gradient == null ? (widget.backgroundColor ?? defaultBackground) : null,
        gradient: widget.gradient,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorder, width: 1.0),
        boxShadow: shadows,
      ),
      child: widget.child,
    );

    if (widget.onTap != null || widget.isHoverable) {
      return MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}
