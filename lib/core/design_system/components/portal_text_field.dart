import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Form input field tailored for Academic Portal forms, logins, and searches.
class PortalTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final bool isSearch;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  const PortalTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.isSearch = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<PortalTextField> createState() => _PortalTextFieldState();
}

class _PortalTextFieldState extends State<PortalTextField> {
  late bool _obscureText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryAccent = isDark ? AppColors.primaryLight : AppColors.primary;
    final fillColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface;
    final defaultBorderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    Widget? effectiveSuffix;
    if (widget.isPassword) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    } else if (widget.suffixIcon != null) {
      effectiveSuffix = widget.suffixIcon;
    }

    final effectivePrefixIcon = widget.isSearch
        ? const Icon(Icons.search_rounded, size: 20)
        : (widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20) : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
        ],
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            enabled: widget.enabled,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: effectivePrefixIcon,
              suffixIcon: effectiveSuffix,
              filled: true,
              fillColor: widget.enabled
                  ? fillColor
                  : (isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.roundedMd,
                borderSide: BorderSide(color: defaultBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.roundedMd,
                borderSide: BorderSide(color: defaultBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.roundedMd,
                borderSide: BorderSide(color: primaryAccent, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppSpacing.roundedMd,
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
