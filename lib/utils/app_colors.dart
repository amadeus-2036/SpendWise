import 'package:flutter/material.dart';

/// SpendWise design system color constants.
/// Carefully curated for a modern, premium fintech aesthetic.
class AppColors {
  // Brand Primary & Navy Accents
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant Blue
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Slate
  static const Color accent = Color(0xFF6366F1); // Indigo Accent

  // Financial Semantics
  static const Color income = Color(0xFF10B981); // Emerald Green
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color expense = Color(0xFFEF4444); // Rose Red
  static const Color expenseLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF0EA5E9); // Sky Blue

  // Light Theme Neutrals
  static const Color lightBg = Color(0xFFF8FAFC); // Clean Canvas
  static const Color lightSurface = Colors.white;
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Dark Theme Neutrals
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF151D2A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Gradient Presets for Hero Cards
  static const LinearGradient cardNavyGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardRedGradient = LinearGradient(
    colors: [Color(0xFF881337), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

