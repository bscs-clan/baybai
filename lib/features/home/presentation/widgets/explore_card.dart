import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";

class ExploreCard extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String? description;
  final VoidCallback? onTap;

  const ExploreCard({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDarkMode ? AppColors.gray40 : AppColors.gray70;
    final labelColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final descriptionColor = contentColor;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: isDarkMode ? AppColors.gray90 : AppColors.bg,
      border: Border.all(
        color: isDarkMode ? AppColors.gray80 : AppColors.gray20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 24, color: AppColors.primary60),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.boldSm.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null) ...[
                Text(
                  description!,
                  style: AppTextStyles.regularXs.copyWith(
                    color: descriptionColor,
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
