import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/common/components/button.dart";

class LearnCard extends StatelessWidget {
  final String lessonNumber;
  final String title;
  final int? lessonId;
  final VoidCallback? onTap;

  final bool isLocked;
  final int currentPage;
  final int totalPages;
  final bool isCompleted;

  const LearnCard({
    super.key,
    required this.lessonNumber,
    required this.title,
    this.lessonId,
    this.onTap,
    this.isLocked = false,
    this.currentPage = 0,
    this.totalPages = 1,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lessonNumber,
                style: AppTextStyles.body.copyWith(
                  color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
                ),
              ),
              if (!isLocked)
                Text(
                  isCompleted
                      ? "$totalPages/$totalPages"
                      : "${currentPage + 1}/$totalPages",
                  style: AppTextStyles.body.copyWith(
                    color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
                  ),
                ),
            ],
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
                : (isCompleted
                    ? "Complete"
                    : (currentPage > 0 ? "Continue" : "Start Lesson")),
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
            type: ButtonType.primary,
            rightIconPath: isLocked ? null : "assets/icons/arrow-right-up.svg",
          ),
        ],
      ),
    );
  }
}
