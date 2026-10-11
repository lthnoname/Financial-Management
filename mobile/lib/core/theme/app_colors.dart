import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF1E40AF); // Blue 800
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF1E3A8A); // Blue 900
  static const Color primaryContainer = Color(0xFFEFF6FF); // Blue 50

  // Secondary colors
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryContainer = Color(0xFFF0FDFA); // Teal 50

  // Financial & semantic colors
  static const Color income = Color(0xFF10B981); // Emerald 500
  static const Color incomeLight = Color(0xFFECFDF5); // Emerald 50
  static const Color expense = Color(0xFFEF4444); // Red 500
  static const Color expenseLight = Color(0xFFFEF2F2); // Red 50

  // Status & feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoLight = Color(0xFFF0F9FF);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & divider
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderFocused = Color(0xFF2563EB); // Blue 600
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Disabled
  static const Color disabled = Color(0xFFCBD5E1); // Slate 300
  static const Color disabledText = Color(0xFF94A3B8);
}
