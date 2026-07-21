import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class ExploreCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback? onTap;
  final bool isLocked;

  const ExploreCard({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final contentColor = isLocked
        ? (isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey)
        : (isDarkMode ? AppColors.darkText : AppColors.dark);
    final labelColor = isLocked
        ? (isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey)
        : (isDarkMode ? AppColors.darkText : AppColors.text);

    return AppCard(
      onTap: isLocked ? null : onTap,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SolarIcon(
            isLocked ? AppSolarIcons.lock : icon,
            size: 24,
            color: contentColor,
          ),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                Text(
                  description!,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppColors.darkTextGrey
                        : AppColors.textGrey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
