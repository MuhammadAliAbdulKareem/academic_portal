import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum PortalAvatarSize {
  sm(32.0, 12.0, 8.0),
  md(40.0, 14.0, 10.0),
  lg(52.0, 18.0, 12.0),
  xl(68.0, 24.0, 14.0);

  final double dimension;
  final double fontSize;
  final double indicatorSize;

  const PortalAvatarSize(this.dimension, this.fontSize, this.indicatorSize);
}

/// User avatar with initials generator, fallback icon, and presence indicator.
class PortalAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final PortalAvatarSize size;
  final bool isOnline;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const PortalAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = PortalAvatarSize.md,
    this.isOnline = false,
    this.backgroundColor,
    this.onTap,
  });

  String _extractInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBg = backgroundColor ??
        (isDark ? AppColors.primary.withValues(alpha: 0.6) : AppColors.primaryLight.withValues(alpha: 0.15));
    final textColor = isDark ? Colors.white : AppColors.primary;

    Widget avatarChild;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarChild = ClipRRect(
        borderRadius: AppSpacing.roundedFull,
        child: Image.network(
          imageUrl!,
          width: size.dimension,
          height: size.dimension,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(textColor),
        ),
      );
    } else {
      avatarChild = _buildInitials(textColor);
    }

    Widget content = Container(
      width: size.dimension,
      height: size.dimension,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      child: Center(child: avatarChild),
    );

    if (isOnline) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size.indicatorSize,
              height: size.indicatorSize,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildInitials(Color textColor) {
    return Text(
      _extractInitials(name),
      style: TextStyle(
        fontSize: size.fontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}
