import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class LearnCard extends StatelessWidget {
  final String lessonNumber;
  final String title;
  final int? lessonId;
  final VoidCallback? onTap;

  final bool isLocked;
  final bool isCompleted;

  const LearnCard({
    super.key,
    required this.lessonNumber,
    required this.title,
    this.lessonId,
    this.onTap,
    this.isLocked = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lessonNumber,
            style: AppTextStyles.body.copyWith(
              color: isDarkMode
                  ? AppColors.darkTextGrey
                  : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.bigbody.copyWith(
              color: isDarkMode ? AppColors.darkText : AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
          Button(
            label: isLocked
                ? "Locked"
                : (isCompleted ? "Complete" : "Start Lesson"),
            onTap: isLocked
                ? null
                : (onTap ??
                      () {
                        Navigator.pushNamed(
                          context,
                          "/lesson",
                          arguments: lessonId ?? 1,
                        );
                      }),
            size: ButtonSize.md,
            type: ButtonType.primary,
            rightIcon: isLocked ? null : AppSolarIcons.arrowRightUp,
          ),
        ],
      ),
    );
  }
}
