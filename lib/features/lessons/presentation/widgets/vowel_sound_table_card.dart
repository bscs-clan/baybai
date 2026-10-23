import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class VowelSoundTableCard extends StatelessWidget {
  final List<LessonCardItem> examples;

  const VowelSoundTableCard({super.key, List<LessonCardItem>? examples})
    : examples = examples ?? _defaultExamples;

  static const List<LessonCardItem> _defaultExamples = [
    LessonCardItem(text: "a", baybayinSymbol: "\u1700"),
    LessonCardItem(text: "e / i", baybayinSymbol: "\u1701"),
    LessonCardItem(text: "o / u", baybayinSymbol: "\u1702"),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final glyphColor = isDarkMode ? AppColors.bg : AppColors.gray100;
    final pillColor = isDarkMode ? AppColors.gray80 : AppColors.primary10;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray80 : AppColors.bg,
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
                _HeaderCell(label: "Vowel Symbol", color: textColor),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Sound", color: textColor),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          ...List.generate(examples.length, (index) {
            final example = examples[index];
            final isLast = index == examples.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            example.baybayinSymbol,
                            style: AppTextStyles.boldXl.copyWith(
                              fontFamily: "Baybayin",
                              fontSize: 32,
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
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              example.text,
                              style: AppTextStyles.boldLg.copyWith(
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final Color color;

  const _HeaderCell({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          label,
          style: AppTextStyles.regularSm.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
