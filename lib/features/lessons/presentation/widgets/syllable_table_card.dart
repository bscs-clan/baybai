import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class _WordExample {
  final List<String> latinLetters;
  final List<String> baybayinSyllables;

  const _WordExample({
    required this.latinLetters,
    required this.baybayinSyllables,
  });
}

class SyllableTableCard extends StatelessWidget {
  const SyllableTableCard({super.key});

  static const List<_WordExample> _examples = [
    _WordExample(
      latinLetters: ["B", "A", "T", "A"],
      baybayinSyllables: ["BA", "TA"],
    ),
    _WordExample(
      latinLetters: ["B", "A", "H", "A", "Y"],
      baybayinSyllables: ["BA", "HA", "Y"],
    ),
    _WordExample(
      latinLetters: ["L", "A", "R", "U", "A", "N"],
      baybayinSyllables: ["LA", "RU", "AN"],
    ),
    _WordExample(
      latinLetters: ["K", "A", "M", "A"],
      baybayinSyllables: ["KA", "MA"],
    ),
    _WordExample(
      latinLetters: ["U", "M", "A", "G", "A"],
      baybayinSyllables: ["U", "MA", "GA"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.grey6;
    final textColor = AppColors.grey12;
    final pillColor = AppColors.blue3;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Latin",
                      style: AppTextStyles.body.copyWith(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "Baybayin Logic",
                      style: AppTextStyles.body.copyWith(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          ...List.generate(_examples.length, (index) {
            final example = _examples[index];
            final isLast = index == _examples.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: isLast ? 14 : 10,
                            left: 4,
                            right: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: example.latinLetters.asMap().entries.map((
                              e,
                            ) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: e.key == 0 ? 0 : 2,
                                ),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey3,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    e.value,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Container(width: 1, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: isLast ? 10 : 8,
                            left: 4,
                            right: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: example.baybayinSyllables
                                .asMap()
                                .entries
                                .map((e) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: e.key == 0 ? 0 : 2,
                                    ),
                                    child: Container(
                                      height: 22,
                                      width: 44,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: pillColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        e.value,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, thickness: 1.0, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}
