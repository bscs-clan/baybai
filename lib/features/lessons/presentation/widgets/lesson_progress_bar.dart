import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";

class LessonProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalLessons;

  const LessonProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(totalLessons, (index) {
              final isCompleted = index <= currentIndex;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : (isDarkMode
                              ? AppColors.darkBox
                              : AppColors.compGrey.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 16),
        const SizedBox(width: 48, height: 48),
      ],
    );
  }
}
