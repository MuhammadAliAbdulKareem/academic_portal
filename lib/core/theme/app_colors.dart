import 'package:flutter/material.dart';

/// Semantic color tokens for the Academic Portal design system.
class AppColors {
  AppColors._();

  // Primary Academic Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Oxford Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant Sapphire
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Navy

  // Secondary & Accent Colors
  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color accentTeal = Color(0xFF0D9488); // Deep Teal
  static const Color accentAmber = Color(0xFFF59E0B); // Academic Gold/Amber

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Light Palette Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Palette Surfaces & Neutrals
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceAlt = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextMuted = Color(0xFF9CA3AF);

  // Decorative Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
