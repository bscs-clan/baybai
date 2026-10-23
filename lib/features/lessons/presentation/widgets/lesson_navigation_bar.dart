import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LessonNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalLessons;
  final VoidCallback? onNext;
  final String? customNextLabel;
  final IconData? customNextIcon;
  final bool showNextIcon;
  final Color? customNextBackgroundColor;
  final Color? customNextForegroundColor;
  final String? feedbackLabel;
  final Color? feedbackColor;
  final Color? navigationBackgroundColor;

  const LessonNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    this.onNext,
    this.customNextLabel,
    this.customNextIcon,
    this.showNextIcon = true,
    this.customNextBackgroundColor,
    this.customNextForegroundColor,
    this.feedbackLabel,
    this.feedbackColor,
    this.navigationBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == totalLessons - 1;
    final label = customNextLabel ?? (isLast ? "Finish" : "Continue");
    final icon = null;
    final isEnabled = onNext != null;

    return Container(
      decoration: BoxDecoration(color: navigationBackgroundColor),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (feedbackLabel != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  HugeIcon(
                    icon: feedbackLabel == "That's right"
                        ? HugeIcons.strokeRoundedParty
                        : HugeIcons.strokeRoundedTired02,
                    size: 24,
                    color: feedbackColor ?? AppColors.gray100,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    feedbackLabel!,
                    style: AppTextStyles.regularSm.copyWith(
                      color: feedbackColor ?? AppColors.gray100,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Button(
            label: label,
            rightIcon: icon,
            type: ButtonType.primary,
            width: double.infinity,
            textStyle: AppTextStyles.boldSm,
            onTap: isEnabled ? onNext : null,
            customBackgroundColor:
                customNextBackgroundColor ?? AppColors.primary60,
            customForegroundColor: customNextForegroundColor,
          ),
        ],
      ),
    );
  }
}
