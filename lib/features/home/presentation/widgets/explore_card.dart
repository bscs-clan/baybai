import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";

class ExploreCard extends StatelessWidget {
  final IconData icon;
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
    final contentColor = AppColors.grey11;
    final labelColor = AppColors.grey12;
    final descriptionColor = AppColors.grey11;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grey5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: contentColor),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null) ...[
                Text(
                  description!,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
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
