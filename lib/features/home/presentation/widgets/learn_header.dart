import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class LearnHeader extends StatelessWidget {
  const LearnHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Text(
          "Let's Begin!",
          style: AppTextStyles.boldXl.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.grey10,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
