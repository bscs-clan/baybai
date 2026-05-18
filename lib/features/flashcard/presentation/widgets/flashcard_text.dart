import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class FlashcardProgress extends StatelessWidget {
  final int currentIndex;
  final int totalCards;

  const FlashcardProgress({
    super.key,
    required this.currentIndex,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Card ${currentIndex + 1} of $totalCards",
        style: AppTextStyles.body.copyWith(
          color: isDarkMode ? AppColors.white : AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
