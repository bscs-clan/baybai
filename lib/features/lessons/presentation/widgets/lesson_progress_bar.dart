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
    final progress = totalLessons > 0 ? (currentIndex + 1) / totalLessons : 0.0;

    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.grey3,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.blue9,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        const SizedBox(width: 48, height: 48),
      ],
    );
  }
}
