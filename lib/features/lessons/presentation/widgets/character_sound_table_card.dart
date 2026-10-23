import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
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

  bool _isBaybayinGlyph(String value) {
    if (value.isEmpty) return false;
    return value.runes.every((codePoint) {
      return codePoint >= 0x1700 && codePoint <= 0x171F;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray80 : AppColors.bg,
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
                      width: 64,
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        example.baybayinSymbol,
                        style: _isBaybayinGlyph(example.baybayinSymbol)
                            ? AppTextStyles.boldXl.copyWith(
                                fontFamily: "Baybayin",
                                fontSize: 30,
                                color: textColor,
                                height: 1.0,
                              )
                            : AppTextStyles.regularSm.copyWith(
                                color: textColor,
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowBigRightDash,
                        color: AppColors.gray30,
                        size: 24,
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 48,
                      alignment: Alignment.center,
                      child: Text(
                        example.text,
                        style: AppTextStyles.boldLg.copyWith(
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
