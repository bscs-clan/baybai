import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkBox : AppColors.box,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SolarIcon(
            AppSolarIcons.arrowLeft,
            size: 24,
            color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
          ),
        ),
      ),
    );
  }
}
