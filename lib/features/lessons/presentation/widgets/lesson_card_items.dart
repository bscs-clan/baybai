import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/shared/components/cards/app_card.dart";

class LessonCardItems extends StatelessWidget {
  final List<LessonCardItem> cardItems;

  const LessonCardItems({super.key, required this.cardItems});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      borderRadius: BorderRadius.circular(32),
      padding: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.only(top: 56, bottom: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: cardItems
              .map((item) => _CardItemTile(item: item, isDarkMode: isDarkMode))
              .toList(),
        ),
      ),
    );
  }
}

class _CardItemTile extends StatelessWidget {
  final LessonCardItem item;
  final bool isDarkMode;

  const _CardItemTile({required this.item, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.text,
          style: AppTextStyles.regularSm.copyWith(
            color: isDarkMode
                ? AppColors.bg.withValues(alpha: 0.5)
                : AppColors.gray100.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          item.baybayinSymbol,
          style: AppTextStyles.boldXl.copyWith(
            fontFamily: 'Baybayin',
            fontSize: 48,
            color: isDarkMode ? AppColors.bg : AppColors.gray100,
            height: 0.60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
