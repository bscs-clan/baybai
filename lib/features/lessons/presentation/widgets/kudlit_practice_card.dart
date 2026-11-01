import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class KudlitPracticeCard extends StatefulWidget {
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

  @override
  State<KudlitPracticeCard> createState() => _KudlitPracticeCardState();
}

class _KudlitPracticeCardState extends State<KudlitPracticeCard> {
  String get _previewSymbol {
    final normalizedOption = widget.selectedOption?.trim().toLowerCase() ?? "";

    if (normalizedOption.contains("top")) {
      return "${widget.baseSymbol}\u1712";
    }
    if (normalizedOption.contains("bottom")) {
      return "${widget.baseSymbol}\u1713";
    }

    return widget.baseSymbol;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final cardBg = isDarkMode ? AppColors.gray80 : AppColors.bg;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final mutedColor = isDarkMode ? AppColors.gray40 : AppColors.gray40;
    final pillColor = isDarkMode ? AppColors.gray80 : AppColors.gray10;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                  sound: widget.baseSound,
                  color: pillColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowBigRightDash,
                  color: mutedColor,
                  size: 24,
                ),
              ),
              Expanded(
                child: _SoundTile(
                  label: "Target",
                  sound: widget.targetSound,
                  color: pillColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gray80 : pillColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Preview",
                  style: AppTextStyles.regularXs.copyWith(
                    color: AppColors.gray60,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 72,
                  child: Center(
                    child: Text(
                      _previewSymbol,
                      style: AppTextStyles.boldXl.copyWith(
                        fontFamily: "Baybayin",
                        fontSize: 48,
                        color: textColor,
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
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

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
            style: AppTextStyles.regularXs.copyWith(color: AppColors.gray60),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sound,
                style: AppTextStyles.boldLg.copyWith(color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
