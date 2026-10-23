import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary60,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary60,
      onPrimary: AppColors.gray10,
      surface: AppColors.gray10,
      onSurface: AppColors.gray100,
      outline: AppColors.gray30,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    brightness: Brightness.light,
    textTheme: TextTheme(
      bodySmall: AppTextStyles.regularSm.copyWith(color: AppColors.gray100),
      bodyMedium: AppTextStyles.regularMd.copyWith(color: AppColors.gray100),
      titleMedium: AppTextStyles.boldLg.copyWith(color: AppColors.gray100),
      headlineMedium: AppTextStyles.bold2xl.copyWith(color: AppColors.gray100),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.primary60,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary60,
      onPrimary: AppColors.gray100,
      surface: AppColors.gray100,
      onSurface: AppColors.gray10,
      outline: AppColors.gray60,
    ),
    scaffoldBackgroundColor: AppColors.gray100,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.gray100,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.gray100,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    brightness: Brightness.dark,
    textTheme: TextTheme(
      bodySmall: AppTextStyles.regularSm.copyWith(color: AppColors.gray10),
      bodyMedium: AppTextStyles.regularMd.copyWith(color: AppColors.gray10),
      titleMedium: AppTextStyles.boldLg.copyWith(color: AppColors.gray10),
      headlineMedium: AppTextStyles.bold2xl.copyWith(color: AppColors.gray10),
    ),
  );
}
