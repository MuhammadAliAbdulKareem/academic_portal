import 'package:flutter/material.dart';

/// Screen device categories.
enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

/// Breakpoint rules and helper utilities for screen categorization.
class Breakpoint {
  Breakpoint._();

  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  /// Determines [DeviceScreenType] given a width.
  static DeviceScreenType fromWidth(double width) {
    if (width >= desktopMin) {
      return DeviceScreenType.desktop;
    } else if (width >= tabletMin) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.mobile;
    }
  }

  /// Determines [DeviceScreenType] given a [MediaQueryData].
  static DeviceScreenType fromMediaQuery(MediaQueryData mediaQuery) {
    return fromWidth(mediaQuery.size.width);
  }
}
