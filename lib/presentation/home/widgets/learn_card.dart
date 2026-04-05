import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/common/components/button.dart";

class LearnCard extends StatelessWidget {
  const LearnCard({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Getting Started",
            style: AppTextStyles.body.copyWith(
              color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Learn the Characters",
            style: AppTextStyles.bigbody.copyWith(
              color: isDarkMode ? AppColors.darkText : AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
          Button(
            label: "Start Lesson",
            iconPath: "assets/icons/arrow-right-up.svg",
            onTap: () {},
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}
