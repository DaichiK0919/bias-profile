import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surfaceTint: Colors.transparent,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'NotoSansJP',// 豆腐対策

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.fontSizeLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.bold,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      cardTheme: CardTheme(
        color: AppColors.tertiary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
        ),
        margin: EdgeInsets.all(AppDimensions.marginMedium),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(AppDimensions.paddingLarge),
        errorStyle: TextStyle(
          color: AppColors.error,
          fontSize: AppDimensions.fontSizeSmall,
          fontFamily: 'NotoSansJP',// 豆腐対策
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
        ),
        titleTextStyle: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansJP',// 豆腐対策
          color: AppColors.primary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
          fontFamily: 'NotoSansJP',// 豆腐対策
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}