import 'package:flutter/material.dart';
import 'breakpoint.dart';

/// Renders distinct widget trees based on active device breakpoint.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenType = Breakpoint.fromWidth(screenWidth);

        switch (screenType) {
          case DeviceScreenType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceScreenType.tablet:
            return tablet ?? mobile;
          case DeviceScreenType.mobile:
            return mobile;
        }
      },
    );
  }
}
