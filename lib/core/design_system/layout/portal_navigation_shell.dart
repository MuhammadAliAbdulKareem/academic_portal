import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/theme_cubit.dart';
import '../../bloc/theme_state.dart';
import '../../constants/app_constants.dart';
import '../../constants/route_constants.dart';
import '../../responsive/responsive_builder.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../components/portal_avatar.dart';
import '../components/portal_badge.dart';

/// Navigation item model representing destination routes.
class PortalNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const PortalNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

/// Adaptive layout shell providing top header, side navigation rail on desktop/tablet,
/// and bottom navigation on mobile devices.
class PortalNavigationShell extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<PortalNavItem> navItems;
  final Widget? trailingHeaderAction;

  const PortalNavigationShell({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.navItems = defaultNavItems,
    this.trailingHeaderAction,
  });

  static const List<PortalNavItem> defaultNavItems = [
    PortalNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      route: '/',
    ),
    PortalNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      route: '/dashboard',
    ),
    PortalNavItem(
      label: 'Design System',
      icon: Icons.palette_outlined,
      selectedIcon: Icons.palette_rounded,
      route: '/design-system',
    ),
    PortalNavItem(
      label: 'Courses',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      route: '/courses',
    ),
    PortalNavItem(
      label: 'Assignments',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment_rounded,
      route: '/assignments',
    ),
  ];

  @override
  State<PortalNavigationShell> createState() => _PortalNavigationShellState();
}

class _PortalNavigationShellState extends State<PortalNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant PortalNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
    }
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    if (widget.onDestinationSelected != null) {
      widget.onDestinationSelected!(index);
    } else {
      if (index >= 0 && index < widget.navItems.length) {
        context.go(widget.navItems[index].route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.isMobile;
        final isDesktop = sizingInfo.isDesktop;

        return Scaffold(
          appBar: _buildTopHeader(context, isDark, isMobile),
          body: Row(
            children: [
              if (!isMobile) _buildSideNavRail(context, isDark, isDesktop),
              Expanded(
                child: widget.child,
              ),
            ],
          ),
          bottomNavigationBar: isMobile ? _buildBottomNav(context, isDark) : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildTopHeader(BuildContext context, bool isDark, bool isMobile) {
    return AppBar(
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkCardGradient : AppColors.primaryGradient,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            AppConstants.appName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return IconButton(
              icon: Icon(
                themeState.themeMode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 20,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            );
          },
        ),
        if (widget.trailingHeaderAction != null) widget.trailingHeaderAction!,
        const SizedBox(width: AppSpacing.xs),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              final user = authState.user;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PortalBadge(
                    label: user.role.displayName.toUpperCase(),
                    variant: user.role.isInstructor
                        ? PortalBadgeVariant.instructor
                        : PortalBadgeVariant.student,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PortalAvatar(
                    name: user.displayName,
                    size: PortalAvatarSize.sm,
                    isOnline: true,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    tooltip: 'Sign Out (${user.displayName})',
                    onPressed: () => context.read<AuthCubit>().logout(),
                  ),
                ],
              );
            }

            return TextButton.icon(
              onPressed: () => context.go(RouteConstants.login),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  Widget _buildSideNavRail(BuildContext context, bool isDark, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        extended: isDesktop,
        minWidth: 72,
        minExtendedWidth: 200,
        backgroundColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: widget.navItems.map((item) {
          return NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onItemTapped,
      destinations: widget.navItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
