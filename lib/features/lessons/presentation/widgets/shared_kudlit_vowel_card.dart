import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class SharedKudlitVowelCard extends StatelessWidget {
  const SharedKudlitVowelCard({super.key});

  static const _examples = [
    _SharedKudlitExample(symbol: "\u170A\u1712", sounds: ["bi", "be"]),
    _SharedKudlitExample(symbol: "\u170A\u1713", sounds: ["bo", "bu"]),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final cardBg = isDarkMode ? AppColors.darkCompBg : AppColors.white;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final pillColor = isDarkMode
        ? AppColors.darkCompLight
        : AppColors.compLight;

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
        children: List.generate(_examples.length, (index) {
          final example = _examples[index];
          final isLast = index == _examples.length - 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        example.symbol,
                        style: AppTextStyles.heading.copyWith(
                          fontFamily: "Baybayin",
                          fontSize: 52,
                          color: textColor,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        "can be",
                        style: AppTextStyles.body.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextGrey
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: example.sounds
                            .map(
                              (sound) => Container(
                                width: 54,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: pillColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  sound,
                                  style: AppTextStyles.body.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1.0, color: borderColor),
              if (!isLast) const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _SharedKudlitExample {
  final String symbol;
  final List<String> sounds;

  const _SharedKudlitExample({required this.symbol, required this.sounds});
}
