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
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final cardBg = isDarkMode ? AppColors.gray80 : AppColors.bg;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final pillColor = isDarkMode ? AppColors.gray80 : AppColors.gray10;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 0 : 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          example.symbol,
                          style: AppTextStyles.boldXl.copyWith(
                            fontFamily: "Baybayin",
                            fontSize: 32,
                            color: textColor,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Can be",
                          style: AppTextStyles.boldSm.copyWith(
                            color: isDarkMode
                                ? AppColors.gray40
                                : AppColors.gray50,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 38),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: pillColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: _capitalize(example.sounds[0])),
                                TextSpan(
                                  text: "  or  ",
                                  style: AppTextStyles.regularSm.copyWith(
                                    color: AppColors.gray50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: _capitalize(example.sounds[1])),
                              ],
                              style: AppTextStyles.boldSm.copyWith(
                                color: textColor,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) ...[
                Divider(height: 1.5, thickness: 1.5, color: borderColor),
                const SizedBox(height: 16),
              ],
            ],
          );
        }),
      ),
    );
  }

  String _capitalize(String sound) =>
      "${sound[0].toUpperCase()}${sound.substring(1)}";
}

class _SharedKudlitExample {
  final String symbol;
  final List<String> sounds;

  const _SharedKudlitExample({required this.symbol, required this.sounds});
}
