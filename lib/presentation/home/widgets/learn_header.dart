import 'package:baybai/core/configs/theme/colors.dart';
import 'package:baybai/core/configs/theme/text.dart';
import 'package:flutter/material.dart';

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
