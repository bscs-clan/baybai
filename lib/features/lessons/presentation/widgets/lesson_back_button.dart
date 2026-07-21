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
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SolarIcon(
            AppSolarIcons.arrowLeft,
            size: 24,
            color: isDarkMode ? AppColors.compLight : AppColors.icon,
          ),
        ),
      ),
    );
  }
}
