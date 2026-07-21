import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class WordToBreakCard extends StatelessWidget {
  final String word;
  final String label;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? labelStyle;
  final TextStyle? wordStyle;

  const WordToBreakCard({
    super.key,
    required this.word,
    this.label = 'Word',
    this.padding = const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
    this.borderRadius = 24,
    this.backgroundColor,
    this.borderColor,
    this.labelStyle,
    this.wordStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final resolvedBorderColor =
        borderColor ??
        (isDarkMode ? AppColors.darkListSeparator : AppColors.listSeparator);
    final resolvedBackgroundColor =
        backgroundColor ??
        (isDarkMode ? AppColors.darkCompBg : AppColors.white);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: resolvedBorderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style:
                labelStyle ??
                AppTextStyles.body.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                ),
          ),
          const SizedBox(height: 18),
          Text(
            word,
            style:
                wordStyle ??
                AppTextStyles.heading.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  letterSpacing: 2,
                  color: isDarkMode ? AppColors.darkText : AppColors.text,
                ),
          ),
        ],
      ),
    );
  }
}
