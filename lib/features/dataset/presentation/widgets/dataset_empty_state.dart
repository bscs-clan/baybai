import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "dart:ui";

class DatasetEmptyState extends StatelessWidget {
  const DatasetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: isDarkMode
                ? const ColorFilter.mode(Colors.white70, BlendMode.modulate)
                : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
            child: Opacity(
              opacity: isDarkMode ? 0.80 : 1,
              child: Image.asset("assets/images/illus_sleep.png", height: 200),
            ),
          ),
          Text(
            "No datasets",
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
