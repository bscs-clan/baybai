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
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final cardBg = isDarkMode ? AppColors.darkCompBg : AppColors.white;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final pillColor = isDarkMode
        ? AppColors.darkCompLight
        : AppColors.compLight;

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
                _HeaderCell(label: "Character", color: textColor),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Kudlit", color: textColor),
                Container(width: 1.5, color: borderColor),
                _HeaderCell(label: "Sound", color: textColor),
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
    final glyphColor = isDarkMode ? AppColors.white : AppColors.dark;

    final baseStyle = AppTextStyles.heading.copyWith(
      fontFamily: "Baybayin",
      fontSize: 44,
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
              color: AppColors.primary,
              background: Paint()
                ..color = AppColors.primary.withValues(alpha: 0.18)
                ..style = PaintingStyle.fill,
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
  final Color color;

  const _HeaderCell({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
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
        ? AppColors.darkText
        : AppColors.text;

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
        style: AppTextStyles.body.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
