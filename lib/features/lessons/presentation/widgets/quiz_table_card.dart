import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class QuizTableCard extends StatelessWidget {
  final String symbol;
  final String? selectedAnswer;
  final bool hasChecked;
  final String? correctOption;

  const QuizTableCard({
    super.key,
    required this.symbol,
    this.selectedAnswer,
    this.hasChecked = false,
    this.correctOption,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final cardBg = isDarkMode ? AppColors.darkCompBg : AppColors.white;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final glyphColor = isDarkMode ? AppColors.white : AppColors.dark;

    final bool isAnswered = selectedAnswer != null;
    final bool isCorrect = hasChecked && selectedAnswer == correctOption;
    final bool isWrong =
        hasChecked && isAnswered && selectedAnswer != correctOption;

    Color slotBorderColor = borderColor;
    Color slotTextColor = textColor;
    Color? slotBg;
    bool dashed = true;

    if (isCorrect) {
      slotBorderColor = AppColors.primary;
      slotBg = AppColors.primary.withValues(alpha: 0.12);
      slotTextColor = AppColors.primary;
      dashed = false;
    } else if (isWrong) {
      slotBorderColor = borderColor;
      slotBg = isDarkMode ? AppColors.darkCompLight : AppColors.compLight;
      slotTextColor = textColor;
      dashed = false;
    }

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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Symbol",
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1.5, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Sound",
                      style: AppTextStyles.body.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1.5, color: borderColor),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      symbol,
                      style: AppTextStyles.heading.copyWith(
                        fontFamily: 'Baybayin',
                        fontSize: 48,
                        color: glyphColor,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(width: 1.5, color: borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _AnswerSlot(
                      answer: selectedAnswer,
                      dashed: dashed,
                      borderColor: slotBorderColor,
                      backgroundColor: slotBg,
                      textColor: slotTextColor,
                      textStyle: AppTextStyles.bigbody.copyWith(
                        color: slotTextColor,
                        fontWeight: FontWeight.w600,
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

class _AnswerSlot extends StatelessWidget {
  final String? answer;
  final bool dashed;
  final Color borderColor;
  final Color? backgroundColor;
  final Color textColor;
  final TextStyle textStyle;

  const _AnswerSlot({
    required this.answer,
    required this.dashed,
    required this.borderColor,
    required this.textColor,
    required this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: CustomPaint(
        painter: dashed
            ? _DashedBorderPainter(color: borderColor, radius: 14)
            : null,
        child: Container(
          decoration: dashed
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: answer != null
                  ? Text(
                      answer!,
                      key: ValueKey(answer),
                      style: textStyle,
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      "_ _ _",
                      key: const ValueKey('empty'),
                      style: textStyle.copyWith(
                        color: borderColor,
                        letterSpacing: 4,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 4.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
          Radius.circular(radius),
        ),
      );

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
