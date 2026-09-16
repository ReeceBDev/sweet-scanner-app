import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// Builds the wireframe [ThemeData] for the Sweet Scanner app: white
/// background, black lines, black text.
abstract final class AppTheme {
  /// The light wireframe theme.
  static ThemeData light() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.background,
      secondary: AppColors.ink,
      onSecondary: AppColors.background,
      error: AppColors.ink,
      onError: AppColors.background,
      surface: AppColors.background,
      onSurface: AppColors.ink,
      outline: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: AppColors.ink,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          side: BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderWidth,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: AppFontSizes.entry,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.borderRadius),
          ),
          side: BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderWidth,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(
            color: AppColors.ink,
            width: AppSizes.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
      ),
    );
  }
}
