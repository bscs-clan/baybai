import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";

class ComponentRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 22;

  const ComponentRadius._();
}

class ComponentSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  const ComponentSpacing._();
}

class ComponentMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 300);

  const ComponentMotion._();
}

class ComponentColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      isDark(context) ? AppColors.darkBox : AppColors.box;

  static Color mutedSurface(BuildContext context) =>
      isDark(context) ? AppColors.darkCompBg : AppColors.compBg;

  static Color inputSurface(BuildContext context) =>
      isDark(context) ? AppColors.darkInputBackground : AppColors.inputBackground;

  static Color foreground(BuildContext context) =>
      isDark(context) ? AppColors.darkWhite : AppColors.text;

  static Color mutedForeground(BuildContext context) =>
      isDark(context) ? AppColors.darkCompGrey : AppColors.textGrey;

  static Color border(BuildContext context) =>
      isDark(context) ? AppColors.darkListSeparator : AppColors.listSeparator;

  const ComponentColors._();
}

class ComponentShadow {
  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.12),
      blurRadius: 16,
      spreadRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> elevated(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withValues(
        alpha: ComponentColors.isDark(context) ? 0.22 : 0.08,
      ),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  const ComponentShadow._();
}
