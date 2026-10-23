import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class KudlitTableCard extends StatelessWidget {
  final List<KudlitTableItem> examples;

  const KudlitTableCard({super.key, List<KudlitTableItem>? examples})
    : examples = examples ?? _defaultExamples;

  static const List<KudlitTableItem> _defaultExamples = [
    KudlitTableItem(baseSymbol: "\u170A", mark: "No kudlit", sound: "ba"),
    KudlitTableItem(
      baseSymbol: "\u170A",
      kudlit: "\u1712",
      mark: "Top kudlit",
      sound: "bi / be",
    ),
    KudlitTableItem(
      baseSymbol: "\u170A",
      kudlit: "\u1713",
      mark: "Bottom kudlit",
      sound: "bu / bo",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final cardBg = isDarkMode ? AppColors.gray80 : AppColors.bg;
    final pillColor = isDarkMode ? AppColors.gray80 : AppColors.gray10;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _HeaderCell(label: "Character"),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Kudlit"),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Sound"),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          ...List.generate(examples.length, (index) {
            final example = examples[index];
            final isLast = index == examples.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: _HighlightedKudlitGlyph(
                              baseSymbol: example.baseSymbol,
                              kudlit: example.kudlit ?? "",
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1.5, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _Pill(label: example.mark, color: pillColor),
                        ),
                      ),
                      Container(width: 1.5, color: borderColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _Pill(label: example.sound, color: pillColor),
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

class _HighlightedKudlitGlyph extends StatelessWidget {
  final String baseSymbol;
  final String kudlit;

  const _HighlightedKudlitGlyph({
    required this.baseSymbol,
    required this.kudlit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final glyphColor = isDarkMode ? AppColors.bg : AppColors.gray100;

    final baseStyle = AppTextStyles.boldXl.copyWith(
      fontFamily: "Baybayin",
      fontSize: 32,
      color: glyphColor,
      height: 1.0,
    );

    if (kudlit.isEmpty) {
      return Text(baseSymbol, style: baseStyle);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: baseSymbol),
          TextSpan(
            text: kudlit,
            style: TextStyle(
              color: AppColors.bgSuccessContrast,
            ),
          ),
        ],
      ),
      style: baseStyle,
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  const _HeaderCell({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Text(
          label,
          style: AppTextStyles.boldSm.copyWith(
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.gray10
        : AppColors.gray100;

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.regularSm.copyWith(
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
