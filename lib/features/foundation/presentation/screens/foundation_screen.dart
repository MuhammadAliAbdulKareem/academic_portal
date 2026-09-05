import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/bloc/theme_cubit.dart';
import '../../../../core/bloc/theme_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Interactive Foundation status and design verification dashboard screen.
class FoundationScreen extends StatelessWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: AppSpacing.roundedSm,
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.primaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_rounded, size: 18),
                    tooltip: 'System Theme',
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_rounded, size: 18),
                    tooltip: 'Light Theme',
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_rounded, size: 18),
                    tooltip: 'Dark Theme',
                  ),
                ],
                selected: {themeState.themeMode},
                onSelectionChanged: (newSelection) {
                  context.read<ThemeCubit>().setThemeMode(newSelection.first);
                },
              );
            },
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalPadding.horizontal / 2,
              vertical: AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Banner Card
                    _buildHeroBanner(context, isDark),
                    const SizedBox(height: AppSpacing.xl),

                    // Architecture Grid
                    _buildArchitectureGrid(context, sizingInfo),
                    const SizedBox(height: AppSpacing.xl),

                    // System Verification Card
                    _buildSystemVerificationCard(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
        borderRadius: AppSpacing.roundedXl,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 4,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppSpacing.roundedFull,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Milestone ${AppConstants.appVersion} — Active',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Academic Portal Platform',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppConstants.appTagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isDark ? AppColors.darkBackground : AppColors.primary,
              elevation: 0,
            ),
            onPressed: () => context.go(RouteConstants.designSystem),
            icon: const Icon(Icons.palette_rounded, size: 18),
            label: const Text('Explore Design System (v0.2.0)'),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureGrid(BuildContext context, ResponsiveInfo sizingInfo) {
    final int crossAxisCount = sizingInfo.isDesktop
        ? 3
        : (sizingInfo.isTablet ? 2 : 1);

    final modules = [
      (
        icon: Icons.architecture_rounded,
        color: AppColors.secondary,
        title: 'Feature-Based Architecture',
        description:
            'Clean separation across Core (Constants, Router, Theme, Bloc, Responsive) and Features modules.',
        badge: 'Validated',
      ),
      (
        icon: Icons.cloud_done_rounded,
        color: AppColors.accentTeal,
        title: 'Firebase Core & Services',
        description:
            'Cross-platform Firebase initialization with graceful fallback for Web, Mobile, and Desktop.',
        badge: 'Initialized',
      ),
      (
        icon: Icons.alt_route_rounded,
        color: AppColors.info,
        title: 'GoRouter Declarative Navigation',
        description:
            'Deep linking, dynamic URL resolution, parameterized routes, and dedicated 404 error fallback.',
        badge: 'Active',
      ),
      (
        icon: Icons.palette_outlined,
        color: AppColors.accentAmber,
        title: 'Design System & Theme Tokens',
        description:
            'Harmonious Oxford sapphire and midnight dark palettes, typography scales, and cohesive components.',
        badge: 'Light / Dark',
      ),
      (
        icon: Icons.devices_rounded,
        color: AppColors.success,
        title: 'Responsive Grid & Breakpoints',
        description:
            'Fluid layout adapting dynamically across mobile (<600px), tablet (600-1024px), and desktop (>1024px).',
        badge: '${sizingInfo.deviceScreenType.name.toUpperCase()} View',
      ),
      (
        icon: Icons.sync_rounded,
        color: AppColors.primaryLight,
        title: 'BLoC State Management',
        description:
            'Predictable reactive state transitions, AppBlocObserver logging, and ThemeCubit integration.',
        badge: 'Cubit Ready',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth -
                ((crossAxisCount - 1) * AppSpacing.md)) /
            crossAxisCount;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: modules.map((item) {
            return SizedBox(
              width: cardWidth,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: AppSpacing.roundedMd,
                            ),
                            child: Icon(item.icon, color: item.color, size: 24),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.08),
                              borderRadius: AppSpacing.roundedFull,
                            ),
                            child: Text(
                              item.badge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSystemVerificationCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Environment & Foundation Health',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatusRow(
              context,
              'Firebase Initialization',
              FirebaseConfig.isInitialized ? 'Active (Ready)' : 'Fallback Mode',
              FirebaseConfig.isInitialized ? AppColors.success : AppColors.warning,
            ),
            const Divider(height: AppSpacing.lg),
            _buildStatusRow(
              context,
              'Viewport Breakpoint',
              '${context.screenType.name.toUpperCase()} (${context.screenWidth.toStringAsFixed(0)} x ${context.screenHeight.toStringAsFixed(0)})',
              AppColors.info,
            ),
            const Divider(height: AppSpacing.lg),
            _buildStatusRow(
              context,
              'Git Branch & Milestone',
              'feature/project-foundation • v0.1.0',
              AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String status,
    Color statusColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
