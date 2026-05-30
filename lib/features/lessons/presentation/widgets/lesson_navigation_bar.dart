import "package:flutter/material.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class LessonNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalLessons;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const LessonNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentIndex > 0)
            Expanded(
              child: Button(
                label: "Previous",
                leftIcon: AppSolarIcons.altArrowLeft,
                onTap: onPrevious,
                type: ButtonType.secondary,
              ),
            )
          else
            const Expanded(child: SizedBox()),
          const SizedBox(width: 8),
          Expanded(
            child: Button(
              label: currentIndex == totalLessons - 1 ? "Finish" : "Next",
              rightIcon: currentIndex == totalLessons - 1
                  ? AppSolarIcons.check
                  : AppSolarIcons.altArrowRight,
              onTap: onNext,
              type: ButtonType.primary,
            ),
          ),
        ],
      ),
    );
  }
}
