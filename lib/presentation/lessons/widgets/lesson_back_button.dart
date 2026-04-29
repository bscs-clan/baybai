import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:baybai/core/configs/theme/colors.dart";

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
          child: SvgPicture.asset(
            "assets/icons/arrow-left.svg",
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.darkIcon : AppColors.icon,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
