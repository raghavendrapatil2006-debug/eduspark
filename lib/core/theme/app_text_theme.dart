import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),

    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),

    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),

    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),

    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),

    bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted),
  );
}
