import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ==========================================================
  // LIGHT THEME
  // ==========================================================

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor:
        AppColors.lightBackground,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.signalOrange,
      brightness: Brightness.light,
    ).copyWith(
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      outline: AppColors.lightBorder,
    ),

    dividerColor:
        AppColors.lightBorder,

    iconTheme: const IconThemeData(
      color: Color(0xFF555A60),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.lightText,
      ),
    ),
  );


  // ==========================================================
  // DARK THEME
  // ==========================================================

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        AppColors.darkBackground,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.signalOrange,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      outline: AppColors.darkBorder,
    ),

    dividerColor:
        AppColors.darkBorder,

    iconTheme: const IconThemeData(
      color: AppColors.darkSubText,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.darkText,
      ),
    ),
  );
}