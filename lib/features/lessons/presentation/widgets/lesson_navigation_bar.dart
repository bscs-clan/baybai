import "package:flutter/material.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LessonNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalLessons;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onRetry;
  final String? customNextLabel;
  final IconData? customNextIcon;
  final bool showNextIcon;
  final Color? customNextBackgroundColor;
  final Color? customNextForegroundColor;

  const LessonNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    this.onPrevious,
    this.onNext,
    this.onRetry,
    this.customNextLabel,
    this.customNextIcon,
    this.showNextIcon = true,
    this.customNextBackgroundColor,
    this.customNextForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == totalLessons - 1;
    final label = customNextLabel ?? (isLast ? "Finish" : "Continue");
    final icon = showNextIcon
        ? (customNextIcon ??
              (isLast ? AppSolarIcons.check : null))
        : null;
    final isEnabled = onNext != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null) ...[
            Button(
              label: "Retry Mistakes",
              leftIcon: AppSolarIcons.undo,
              type: ButtonType.outline,
              width: double.infinity,
              onTap: onRetry,
            ),
            const SizedBox(height: 8),
          ],
          Button(
            label: label,
            rightIcon: icon,
            type: ButtonType.primary,
            width: double.infinity,
            textStyle: AppTextStyles.body,
            onTap: isEnabled ? onNext : null,
            customBackgroundColor: customNextBackgroundColor,
            customForegroundColor: customNextForegroundColor,
          ),
        ],
      ),
    );
  }
}
