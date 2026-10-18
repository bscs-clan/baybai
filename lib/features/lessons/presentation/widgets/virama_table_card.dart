import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class ViramaTableCard extends StatelessWidget {
  final bool showExplanations;

  const ViramaTableCard({super.key, this.showExplanations = false});

  static const List<_ViramaExample> _examples = [
    _ViramaExample(
      symbol: "\u170A",
      sound: "ba",
      label: "Without virama",
      description: "The default vowel is present.",
    ),
    _ViramaExample(
      symbol: "\u170A\u1714",
      sound: "b",
      label: "With virama",
      description: "Virama removes the a vowel.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_examples.length, (index) {
          final example = _examples[index];
          final isLast = index == _examples.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isLast ? 16 : 12,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 64,
                      child: Center(
                        child: Text(
                          example.symbol,
                          style: AppTextStyles.heading.copyWith(
                            fontFamily: "Baybayin",
                            fontSize: 40,
                            color: textColor,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            example.sound,
                            style: AppTextStyles.bigbody.copyWith(
                              color: textColor,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            showExplanations
                                ? example.description
                                : example.label,
                            style: AppTextStyles.body.copyWith(
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

class _ViramaExample {
  final String symbol;
  final String sound;
  final String label;
  final String description;

  const _ViramaExample({
    required this.symbol,
    required this.sound,
    required this.label,
    required this.description,
  });
}
