import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class FinalConsonantCard extends StatelessWidget {
  const FinalConsonantCard({super.key});

  static const List<_FinalConsonantExplanation> _explanations = [
    _FinalConsonantExplanation(
      title: "Traditional Baybayin",
      description: "uses the original writing system, where consonants have an inherent “a” vowel sound.",
      example: "BATA",
      baybayin: "\u170A\u1706",
    ),
    _FinalConsonantExplanation(
      title: "Modern Baybayin",
      description: "uses added marks, such as the virama, to represent consonants without a vowel.",
      example: "BUNDOK",
      baybayin: "\u170A\u1713\u1708\u1714\u1707\u1713\u1703\u1714",
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
                        style: AppTextStyles.boldSm.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        explanation.description,
                        style: AppTextStyles.regularSm.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            explanation.example,
                            style: AppTextStyles.boldSm.copyWith(
                              color: AppColors.gray80,
                            ),
                          ),
                          Text(
                            explanation.baybayin,
                            textAlign: TextAlign.left,
                            style: AppTextStyles.regularSm.copyWith(
                              color: textColor,
                              fontSize: 28,
                              fontFamily: "Baybayin",
                            ),
                          ),
                        ],
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
  final String example;
  final String baybayin;

  const _FinalConsonantExplanation({
    required this.title,
    required this.description,
    required this.example,
    required this.baybayin,
  });
}
