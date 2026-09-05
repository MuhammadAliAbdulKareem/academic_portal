import 'package:flutter/material.dart';

/// Standard elevation and shadow tokens for the Academic Portal design system.
class AppShadows {
  AppShadows._();

  // Subtle ambient card shadow (Light mode)
  static const List<BoxShadow> lightCard = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Elevated interactive card shadow on hover / focus (Light mode)
  static const List<BoxShadow> lightHover = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // Floating modal / navigation rail shadow (Light mode)
  static const List<BoxShadow> lightFloating = [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  // Dark mode subtle elevation
  static const List<BoxShadow> darkCard = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Dark mode hover elevation with subtle sapphire tint glow
  static const List<BoxShadow> darkHover = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x203B82F6),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  // Accent Primary Button Glow
  static List<BoxShadow> buttonGlow(Color primaryColor) => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}
