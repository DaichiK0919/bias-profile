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
      fontFamily: 'NotoSansJP',

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
          color: AppColors.primary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: TextStyle(
          fontSize: AppDimensions.fontSizeMedium,
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