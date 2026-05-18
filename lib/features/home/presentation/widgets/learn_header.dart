import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class LearnHeader extends StatelessWidget {
  final String userName;

  const LearnHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mabuhay, $userName",
          style: AppTextStyles.body.copyWith(
            color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Ready to learn Baybayin?",
          style: AppTextStyles.heading.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          ),
        ),
      ],
    );
  }
}
