import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/presentation/home/widgets/learn_card.dart";

class TabLearn extends StatelessWidget {
  const TabLearn({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mabuhay, Deobert",
              style: AppTextStyles.body.copyWith(
                color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Ready to learn Baybayin?",
              style: AppTextStyles.heading.copyWith(
                color: isDarkMode ? AppColors.darkText : AppColors.text,
              ),
            ),
            SizedBox(height: 24),
            LearnCard(),
          ],
        ),
      ),
    );
  }
}
