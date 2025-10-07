import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.orange,
      onPrimary: AppColors.white,
      secondary: AppColors.blue,
      onSecondary: AppColors.white,
      error: Colors.red,
      onError: AppColors.white,
      background: AppColors.sky,
      onBackground: AppColors.navy,
      surface: AppColors.white,
      onSurface: AppColors.navy,
    ),
    scaffoldBackgroundColor: AppColors.sky,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: AppColors.gray700,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: AppColors.gray700.withOpacity(0.6),
        fontSize: 15,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 36,
      ),
      titleLarge: TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      bodyLarge: TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.gray700,
        fontWeight: FontWeight.w400,
        fontSize: 15,
      ),
      labelLarge: TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  );
}
