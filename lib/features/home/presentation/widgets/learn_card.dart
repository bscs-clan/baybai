import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LearnCard extends StatelessWidget {
  final String lessonNumber;
  final String title;
  final String description;
  final int? lessonId;
  final VoidCallback? onTap;

  final bool isLocked;
  final bool isCompleted;
  final IconData? icon;

  const LearnCard({
    super.key,
    required this.lessonNumber,
    required this.title,
    this.description =
        "Learn the basics of Baybayin and how words are written by sound.",
    this.lessonId,
    this.onTap,
    this.isLocked = false,
    this.isCompleted = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final VoidCallback? effectiveTap = isLocked
        ? null
        : (onTap ??
              () {
                Navigator.pushNamed(
                  context,
                  "/lesson",
                  arguments: lessonId ?? 1,
                );
              });
    final String buttonLabel;
    if (isLocked) {
      buttonLabel = "Locked";
    } else if (isCompleted) {
      buttonLabel = "Review Lesson";
    } else {
      buttonLabel = "Start Lesson";
    }

    final buttonBackgroundColor = isLocked
        ? AppColors.textGrey
        : AppColors.primary;

    return AppCard(
      width: double.infinity,
      padding: EdgeInsets.zero,
      backgroundColor: isDarkMode ? AppColors.darkCompBg : AppColors.box,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.background.withValues(alpha: 0.8),
          blurRadius: 16,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ],
      child: ClipRRect(
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonNumber,
                    style: AppTextStyles.body.copyWith(
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.textGrey,
                    ),
                  ),
                  Text(
                    title,
                    style: AppTextStyles.bigbody.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IntrinsicWidth(
                      child: Button(
                        borderRadius: BorderRadius.circular(64),
                        label: buttonLabel,
                        onTap: effectiveTap,
                        customBackgroundColor: buttonBackgroundColor,
                        customForegroundColor: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
