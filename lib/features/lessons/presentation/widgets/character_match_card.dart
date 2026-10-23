import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class CharacterMatchCard extends StatelessWidget {
  final List<String> characters;
  final List<Widget> answerSlots;
  final bool isDarkMode;

  const CharacterMatchCard({
    super.key,
    required this.characters,
    required this.answerSlots,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray90 : AppColors.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray20),
      ),
      child: Column(
        children: List.generate(characters.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == characters.length - 1 ? 0 : 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.gray80 : AppColors.gray10,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    characters[index],
                    style: AppTextStyles.boldXl.copyWith(
                      fontFamily: "Baybayin",
                      fontSize: 34,
                      color: textColor,
                      height: 1.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowBigRightDash,
                    color: AppColors.gray30,
                    size: 24,
                  ),
                ),
                Expanded(child: answerSlots[index]),
              ],
            ),
          );
        }),
      ),
    );
  }
}
