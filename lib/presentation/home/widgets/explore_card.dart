import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";

class ExploreCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const ExploreCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkBox : AppColors.box,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: isDarkMode ? AppColors.darkCompBg : AppColors.compLight,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.darkText : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
