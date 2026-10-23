import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class QuizTableCard extends StatelessWidget {
  final String symbol;
  final String? selectedAnswer;
  final bool hasChecked;
  final String? correctOption;

  const QuizTableCard({
    super.key,
    required this.symbol,
    this.selectedAnswer,
    this.hasChecked = false,
    this.correctOption,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final cardBg = isDarkMode ? AppColors.gray80 : AppColors.bg;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final glyphColor = isDarkMode ? AppColors.bg : AppColors.gray100;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Symbol",
                      style: AppTextStyles.boldSm.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1.5, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Sound",
                      style: AppTextStyles.boldSm.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      symbol,
                      style: AppTextStyles.boldXl.copyWith(
                        fontFamily: "Baybayin",
                        fontSize: 48,
                        color: glyphColor,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1.5, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _AnswerSlot(
                      answer: selectedAnswer,
                      backgroundColor: AppColors.gray10,
                      textColor: textColor,
                      textStyle: AppTextStyles.boldLg.copyWith(
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerSlot extends StatelessWidget {
  final String? answer;
  final Color? backgroundColor;
  final Color textColor;
  final TextStyle textStyle;

  const _AnswerSlot({
    required this.answer,
    required this.textColor,
    required this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: answer != null
            ? Text(
                answer!,
                style: textStyle.copyWith(color: textColor),
                textAlign: TextAlign.center,
              )
            : null,
      ),
    );
  }
}
