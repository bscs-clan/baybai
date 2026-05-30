import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class ExploreCard extends StatelessWidget {
  final IconData icon;
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

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
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
              child: SolarIcon(
                icon,
                size: 24,
                color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
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
    );
  }
}
