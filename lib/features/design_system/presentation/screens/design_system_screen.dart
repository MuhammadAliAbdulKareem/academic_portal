import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/components/portal_avatar.dart';
import '../../../../core/design_system/components/portal_badge.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_empty_state.dart';
import '../../../../core/design_system/components/portal_skeleton.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Interactive Design System showcase screen allowing live inspection of all UI components.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  bool _isButtonLoading = false;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 1,
      onDestinationSelected: (index) {
        if (index == 0) {
          context.go(RouteConstants.root);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveHorizontalPadding.horizontal / 2,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildPageHeader(context),
            const SizedBox(height: AppSpacing.xl),

            // Color Palette
            _buildSection(
              context,
              title: 'Color Palette Tokens',
              subtitle: 'Semantic primary, surface, and feedback colors.',
              child: _buildColorPalette(context, isDark),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Buttons Gallery
            _buildSection(
              context,
              title: 'Interactive Buttons',
              subtitle: 'Multi-variant button system with loading states, sizes, and hover micro-interactions.',
              child: _buildButtonsGallery(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Form Inputs
            _buildSection(
              context,
              title: 'Form Inputs & Text Fields',
              subtitle: 'Standard, search, and secure password fields with validation states.',
              child: _buildFormInputs(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Badges & Status Tags
            _buildSection(
              context,
              title: 'Badges & Indicators',
              subtitle: 'Role tags, course statuses, and notification indicators.',
              child: _buildBadgesGallery(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Avatars & User Cards
            _buildSection(
              context,
              title: 'Avatars & Presence',
              subtitle: 'Initials fallback, customizable dimensions, and online status.',
              child: _buildAvatarsGallery(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Skeleton Shimmers & Empty States
            _buildSection(
              context,
              title: 'Loading Skeletons & Empty States',
              subtitle: 'Animated shimmer placeholders and empty collection components.',
              child: _buildFeedbackComponents(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PortalBadge(
              label: 'DESIGN SYSTEM v0.2.0',
              variant: PortalBadgeVariant.primary,
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(width: AppSpacing.sm),
            PortalBadge(
              label: 'ATOMIC LIBRARY',
              variant: PortalBadgeVariant.secondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Academic Portal Component Library',
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Reusable, accessible, and responsive components built for higher education learning management.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return PortalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
          const Divider(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context, bool isDark) {
    final colors = [
      ('Primary', AppColors.primary, '#1E3A8A'),
      ('Primary Light', AppColors.primaryLight, '#3B82F6'),
      ('Secondary', AppColors.secondary, '#6366F1'),
      ('Teal Accent', AppColors.accentTeal, '#0D9488'),
      ('Success', AppColors.success, '#10B981'),
      ('Warning', AppColors.warning, '#F59E0B'),
      ('Error', AppColors.error, '#EF4444'),
      ('Midnight Navy', AppColors.darkBackground, '#0B0F19'),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: colors.map((c) {
        return Container(
          width: 130,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: c.$2,
                  borderRadius: AppSpacing.roundedSm,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                c.$1,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                c.$3,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtonsGallery(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PortalButton(
              label: 'Primary Action',
              onPressed: () {},
              icon: Icons.check_circle_outline_rounded,
            ),
            PortalButton(
              label: 'Secondary Action',
              variant: PortalButtonVariant.secondary,
              onPressed: () {},
              icon: Icons.layers_outlined,
            ),
            PortalButton(
              label: 'Outline Button',
              variant: PortalButtonVariant.outline,
              onPressed: () {},
            ),
            PortalButton(
              label: 'Ghost Button',
              variant: PortalButtonVariant.ghost,
              onPressed: () {},
            ),
            PortalButton(
              label: 'Destructive',
              variant: PortalButtonVariant.destructive,
              onPressed: () {},
              icon: Icons.delete_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            PortalButton(
              label: _isButtonLoading ? 'Processing...' : 'Toggle Loading State',
              variant: PortalButtonVariant.primary,
              isLoading: _isButtonLoading,
              onPressed: () {
                setState(() => _isButtonLoading = !_isButtonLoading);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _isButtonLoading = false);
                });
              },
            ),
            const SizedBox(width: AppSpacing.md),
            const PortalButton(
              label: 'Disabled Button',
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormInputs(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PortalTextField(
                label: 'Course Code / Title',
                hintText: 'e.g. CS-401 Advanced Algorithms',
                prefixIcon: Icons.book_outlined,
                controller: _textController,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: PortalTextField(
                label: 'Search Catalog',
                hintText: 'Search courses, instructors, materials...',
                isSearch: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: PortalTextField(
                label: 'Account Password',
                hintText: 'Enter your secure password',
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: PortalTextField(
                label: 'Disabled Input Field',
                hintText: 'Field is currently read-only',
                enabled: false,
                prefixIcon: Icons.block_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgesGallery(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: const [
        PortalBadge(label: 'Instructor', variant: PortalBadgeVariant.instructor, icon: Icons.psychology_outlined),
        PortalBadge(label: 'Student', variant: PortalBadgeVariant.student, icon: Icons.school_outlined),
        PortalBadge(label: 'Published', variant: PortalBadgeVariant.success, hasDot: true),
        PortalBadge(label: 'Draft', variant: PortalBadgeVariant.warning, hasDot: true),
        PortalBadge(label: 'Overdue', variant: PortalBadgeVariant.error, hasDot: true),
        PortalBadge(label: 'Information', variant: PortalBadgeVariant.info, icon: Icons.info_outline_rounded),
        PortalBadge(label: 'Archived', variant: PortalBadgeVariant.neutral),
      ],
    );
  }

  Widget _buildAvatarsGallery(BuildContext context) {
    return Row(
      children: const [
        PortalAvatar(name: 'Dr. Alan Turing', size: PortalAvatarSize.xl, isOnline: true),
        SizedBox(width: AppSpacing.md),
        PortalAvatar(name: 'Ada Lovelace', size: PortalAvatarSize.lg, isOnline: true),
        SizedBox(width: AppSpacing.md),
        PortalAvatar(name: 'Grace Hopper', size: PortalAvatarSize.md, isOnline: false),
        SizedBox(width: AppSpacing.md),
        PortalAvatar(name: 'Student Portal', size: PortalAvatarSize.sm, isOnline: false),
      ],
    );
  }

  Widget _buildFeedbackComponents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            PortalSkeleton.circle(size: 44),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PortalSkeleton.line(width: 220, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  PortalSkeleton.line(width: 140, height: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const PortalEmptyState(
          title: 'No Course Materials Found',
          description: 'Upload lectures, slides, and syllabus documents to get started.',
          icon: Icons.folder_open_rounded,
          actionLabel: 'Upload Material',
        ),
      ],
    );
  }
}
