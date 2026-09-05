import 'package:flutter/material.dart';
import 'breakpoint.dart';

/// Extension helpers on [BuildContext] for responsive layout checks and dimensions.
extension ResponsiveContextExtensions on BuildContext {
  /// The total width of the screen.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// The total height of the screen.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Current [DeviceScreenType].
  DeviceScreenType get screenType => Breakpoint.fromWidth(screenWidth);

  /// Returns true if screen width is under 600px.
  bool get isMobile => screenType == DeviceScreenType.mobile;

  /// Returns true if screen width is between 600px and 1023px.
  bool get isTablet => screenType == DeviceScreenType.tablet;

  /// Returns true if screen width is 1024px or higher.
  bool get isDesktop => screenType == DeviceScreenType.desktop;

  /// Dynamic horizontal padding based on screen width.
  EdgeInsets get responsiveHorizontalPadding {
    if (isDesktop) {
      return const EdgeInsets.symmetric(horizontal: 48.0);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }
}
