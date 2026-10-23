import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class FinalConsonantCard extends StatelessWidget {
  const FinalConsonantCard({super.key});

  static const List<_FinalConsonantExplanation> _explanations = [
    _FinalConsonantExplanation(
      title: "Traditional Baybayin",
      description: "Some final consonants may be left unwritten.",
    ),
    _FinalConsonantExplanation(
      title: "Modern Baybayin",
      description: "Virama can indicate the final consonant.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray80 : AppColors.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_explanations.length, (index) {
          final explanation = _explanations[index];
          final isLast = index == _explanations.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isLast ? 16 : 12,
                  horizontal: 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        explanation.title,
                        style: AppTextStyles.regularSm.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        explanation.description,
                        style: AppTextStyles.regularSm.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast) Divider(height: 1, thickness: 1, color: borderColor),
            ],
          );
        }),
      ),
    );
  }
}

class _FinalConsonantExplanation {
  final String title;
  final String description;

  const _FinalConsonantExplanation({
    required this.title,
    required this.description,
  });
}
