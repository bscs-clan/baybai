import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class CharacterSoundTableCard extends StatelessWidget {
  final List<LessonCardItem> examples;

  const CharacterSoundTableCard({super.key, List<LessonCardItem>? examples})
    : examples = examples ?? _defaultExamples;

  static const List<LessonCardItem> _defaultExamples = [
    LessonCardItem(text: "Ba", baybayinSymbol: "\u170A"),
    LessonCardItem(text: "Ka", baybayinSymbol: "\u1703"),
    LessonCardItem(text: "Ma", baybayinSymbol: "\u170B"),
    LessonCardItem(text: "Sa", baybayinSymbol: "\u1710"),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final pillColor = isDarkMode
        ? AppColors.darkCompLight
        : AppColors.compLight;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(examples.length, (index) {
          final example = examples[index];
          final isLast = index == examples.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isLast ? 16 : 12,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        example.baybayinSymbol,
                        style: AppTextStyles.heading.copyWith(
                          fontFamily: "Baybayin",
                          fontSize: 30,
                          color: textColor,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: textColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        example.text,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1.0, color: borderColor),
            ],
          );
        }),
      ),
    );
  }
}
