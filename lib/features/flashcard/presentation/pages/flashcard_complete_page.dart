import "dart:math" as math;
import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/flashcard/presentation/pages/flashcard_page.dart";
import "package:baybai/shared/components/buttons/button.dart";

class FlashcardQuestionResult {
  final int? questionNumber;
  final String question;
  final String status;

  const FlashcardQuestionResult({
    required this.questionNumber,
    required this.question,
    required this.status,
  });
}

class FlashcardCompletePage extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int skippedAnswers;
  final String? cardCount;
  final List<FlashcardQuestionResult> questionResults;

  const FlashcardCompletePage({
    super.key,
    this.correctAnswers = 30,
    this.totalQuestions = 30,
    this.skippedAnswers = 0,
    this.cardCount,
    this.questionResults = const [],
  });

  @override
  State<FlashcardCompletePage> createState() => _FlashcardCompletePageState();
}

class _FlashcardCompletePageState extends State<FlashcardCompletePage> {
  String selectedQuestionType = 'Correct';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.background;
    final wrongAnswers =
        widget.totalQuestions - widget.correctAnswers - widget.skippedAnswers;
    final scorePercentage = widget.totalQuestions == 0
        ? 0
        : ((widget.correctAnswers / widget.totalQuestions) * 100).round();
    final visibleQuestions = widget.questionResults
        .where((result) => result.status == selectedQuestionType)
        .toList(growable: false);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Result',
                    style: AppTextStyles.body.copyWith(color: AppColors.grey10),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.correctAnswers}/${widget.totalQuestions}',
                        style: AppTextStyles.bigbody,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: SizedBox(
                        width: 164,
                        height: 164,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(164, 164),
                              painter: ScoreCirclePainter(
                                correctFraction: widget.totalQuestions == 0
                                    ? 0
                                    : widget.correctAnswers /
                                          widget.totalQuestions,
                                wrongFraction: widget.totalQuestions == 0
                                    ? 0
                                    : wrongAnswers / widget.totalQuestions,
                              ),
                            ),
                            Text(
                              '$scorePercentage%',
                              style: AppTextStyles.bigbody.copyWith(
                                color: AppColors.grey11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ScoreLegendItem(
                          color: AppColors.blue9,
                          label: 'Got It',
                          count: widget.correctAnswers,
                        ),
                        _ScoreLegendItem(
                          color: AppColors.blue5,
                          label: 'Missed',
                          count: wrongAnswers,
                        ),
                        _ScoreLegendItem(
                          color: AppColors.grey4,
                          label: 'Skipped',
                          count: widget.skippedAnswers,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.grey6,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        selectedQuestionType,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.grey12,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        color: AppColors.grey1,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: AppColors.grey3),
                        ),
                        tooltip: 'Select question type',
                        onSelected: (value) {
                          setState(() {
                            selectedQuestionType = value;
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'Skipped',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.remove,
                                  color: AppColors.grey9,
                                ),
                                const SizedBox(width: 12),
                                Text('Skipped', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Got It',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, color: AppColors.grey9),
                                const SizedBox(width: 12),
                                Text('Got It', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Missed',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.close, color: AppColors.grey9),
                                const SizedBox(width: 12),
                                Text('Missed', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: visibleQuestions.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final result = visibleQuestions[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${result.questionNumber ?? index + 1}.',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.grey12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.question,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.grey12,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          label: 'Try Again',
                          width: double.infinity,
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  FlashcardPage(cardCount: widget.cardCount),
                            ),
                          ),
                          type: ButtonType.outline,
                          customBorderColor: AppColors.grey5,
                          size: ButtonSize.md,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Button(
                          label: 'Done',
                          width: double.infinity,
                          onTap: () => Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/home', (route) => false),
                          type: ButtonType.primary,
                          size: ButtonSize.md,
                          customBackgroundColor: AppColors.blue9,
                          customForegroundColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _ScoreLegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey3,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: AppTextStyles.body.copyWith(color: AppColors.grey12),
          ),
        ],
      ),
    );
  }
}

class ScoreCirclePainter extends CustomPainter {
  final double correctFraction;
  final double wrongFraction;

  const ScoreCirclePainter({double? correctFraction, double? wrongFraction})
    : correctFraction = correctFraction ?? 0,
      wrongFraction = wrongFraction ?? 0;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 20.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = AppColors.grey4
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final blue9Paint = Paint()
      ..color = AppColors.blue9
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final blue5Paint = Paint()
      ..color = AppColors.blue5
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const startAngle = -math.pi / 2;
    final blue9Sweep = 2 * math.pi * correctFraction.clamp(0, 1);
    final blue5Sweep = 2 * math.pi * wrongFraction.clamp(0, 1);

    canvas.drawArc(rect, startAngle, blue9Sweep, false, blue9Paint);

    canvas.drawArc(
      rect,
      startAngle + blue9Sweep,
      blue5Sweep,
      false,
      blue5Paint,
    );
  }

  @override
  bool shouldRepaint(covariant ScoreCirclePainter oldDelegate) {
    return correctFraction != oldDelegate.correctFraction ||
        wrongFraction != oldDelegate.wrongFraction;
  }
}
