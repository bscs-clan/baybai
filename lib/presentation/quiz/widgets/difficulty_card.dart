import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";

enum QuizMode { practice, challenge }

class QuizModeInfo {
  final QuizMode mode;
  final String title;
  final String description;
  final bool hasTimer;
  final bool hasHints;
  final String icon;
  final Color accentColor;

  const QuizModeInfo({
    required this.mode,
    required this.title,
    required this.description,
    required this.hasTimer,
    required this.hasHints,
    required this.icon,
    required this.accentColor,
  });
}

final List<QuizModeInfo> quizModes = [
  const QuizModeInfo(
    mode: QuizMode.practice,
    title: "Practice Mode",
    description:
        "Review each character at your own pace with helpful tips recommended for beginners ",
    hasTimer: false,
    hasHints: true,
    icon: "assets/icons/academic-cap.svg",
    accentColor: AppColors.primary,
  ),
  const QuizModeInfo(
    mode: QuizMode.challenge,
    title: "Challenge Mode",
    description:
        "Test your speed and accuracy with mixed difficulty questions to test your mastery",
    hasTimer: true,
    hasHints: false,
    icon: "assets/icons/cup.svg",
    accentColor: AppColors.primary,
  ),
];

class ModeCard extends StatelessWidget {
  final QuizModeInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color baseColor = isDarkMode ? AppColors.darkBox : AppColors.box;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: baseColor,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          shadows: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [], // 👈 NO SHADOW when unselected
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: info.accentColor.withValues(alpha: 0.15),
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      info.icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        info.accentColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    info.title,
                    style: AppTextStyles.title.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              info.description,
              style: AppTextStyles.mbody.copyWith(
                color: isDarkMode ? AppColors.white : AppColors.text,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _InfoChip(
                  icon: info.hasTimer
                      ? "assets/icons/alarm.svg"
                      : "assets/icons/alarm-off.svg",
                  label: info.hasTimer ? "Timer on" : "No timer",
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 6),
                _InfoChip(
                  icon: info.hasHints
                      ? "assets/icons/lightbulb.svg"
                      : "assets/icons/close.svg",
                  label: info.hasHints ? "Hints on" : "No hints",
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool isDarkMode;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.white : AppColors.dark,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.mbody.copyWith(
              fontSize: 12,
              color: isDarkMode ? AppColors.white : AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
