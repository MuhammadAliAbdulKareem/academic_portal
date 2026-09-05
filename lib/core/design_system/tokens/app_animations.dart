import 'package:flutter/animation.dart';

/// Micro-interaction timings and animation curves for fluid UI transitions.
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 400);

  // Curves
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
}
