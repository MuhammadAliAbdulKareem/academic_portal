import 'package:flutter/material.dart';
import 'breakpoint.dart';

/// Contextual sizing information supplied to [ResponsiveBuilder].
class ResponsiveInfo {
  final DeviceScreenType deviceScreenType;
  final Size screenSize;
  final BoxConstraints localConstraints;

  const ResponsiveInfo({
    required this.deviceScreenType,
    required this.screenSize,
    required this.localConstraints,
  });

  bool get isMobile => deviceScreenType == DeviceScreenType.mobile;
  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;
  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;
}

/// Widget builder that exposes [ResponsiveInfo] for fine-grained adaptive sizing.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo sizingInfo) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final sizingInfo = ResponsiveInfo(
          deviceScreenType: Breakpoint.fromWidth(mediaQuery.size.width),
          screenSize: mediaQuery.size,
          localConstraints: constraints,
        );

        return builder(context, sizingInfo);
      },
    );
  }
}
