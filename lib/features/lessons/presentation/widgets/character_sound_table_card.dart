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
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color:AppColors.grey3,
                        size: 24,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        example.text,
                        style: AppTextStyles.body.copyWith(
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
