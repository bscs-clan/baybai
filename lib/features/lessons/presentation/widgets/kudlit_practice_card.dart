import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class KudlitPracticeCard extends StatelessWidget {
  final String baseSymbol;
  final String baseSound;
  final String targetSound;
  final String? selectedOption;

  const KudlitPracticeCard({
    super.key,
    required this.baseSymbol,
    required this.baseSound,
    required this.targetSound,
    this.selectedOption,
  });

  String get _previewSymbol {
    final normalizedOption = selectedOption?.trim().toLowerCase() ?? "";

    if (normalizedOption.contains("top")) {
      return "$baseSymbol\u1712";
    }
    if (normalizedOption.contains("bottom")) {
      return "$baseSymbol\u1713";
    }

    return baseSymbol;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final cardBg = isDarkMode ? AppColors.darkCompBg : AppColors.white;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final mutedColor = isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey;
    final pillColor = isDarkMode ? AppColors.darkCompLight : AppColors.compLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _SoundTile(
                  label: "Start",
                  sound: baseSound,
                  color: pillColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded, color: mutedColor, size: 22),
              ),
              Expanded(
                child: _SoundTile(
                  label: "Target",
                  sound: targetSound,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCompLight : AppColors.compLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Preview",
                  style: AppTextStyles.body.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 72,
                  child: Center(
                    child: Text(
                      _previewSymbol,
                      style: AppTextStyles.heading.copyWith(
                        fontFamily: "Baybayin",
                        fontSize: 58,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  final String label;
  final String sound;
  final Color color;

  const _SoundTile({
    required this.label,
    required this.sound,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final mutedColor = isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: mutedColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sound,
            style: AppTextStyles.bigbody.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
