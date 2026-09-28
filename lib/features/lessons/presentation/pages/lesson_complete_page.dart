import "dart:math" as math;

import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LessonQuestionResult {
  final int questionNumber;
  final String question;
  final String status;

  const LessonQuestionResult({
    required this.questionNumber,
    required this.question,
    required this.status,
  });
}

class LessonCompletePage extends StatefulWidget {
  final int lessonId;
  final int correctAnswers;
  final int totalQuestions;
  final int skippedAnswers;
  final Duration elapsedTime;
  final List<LessonQuestionResult> questionResults;

  const LessonCompletePage({
    super.key,
    required this.lessonId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.skippedAnswers,
    required this.elapsedTime,
    required this.questionResults,
  });

  @override
  State<LessonCompletePage> createState() => _LessonCompletePageState();
}

class _LessonCompletePageState extends State<LessonCompletePage> {
  String _selectedQuestionType = "Correct";

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final wrongAnswers =
        widget.totalQuestions - widget.correctAnswers - widget.skippedAnswers;
    final scorePercentage = widget.totalQuestions == 0
        ? 0
        : ((widget.correctAnswers / widget.totalQuestions) * 100).round();
    final visibleQuestions = widget.questionResults
        .where((result) => result.status == _selectedQuestionType)
        .toList(growable: false);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Score",
                  style: AppTextStyles.body.copyWith(color: AppColors.grey10),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.correctAnswers}/${widget.totalQuestions}",
                      style: AppTextStyles.bigbody,
                    ),
                    Text(
                      _formatElapsedTime(widget.elapsedTime),
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
                            painter: _ScoreCirclePainter(
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
                            "$scorePercentage%",
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
                        label: "Correct",
                        count: widget.correctAnswers,
                      ),
                      _ScoreLegendItem(
                        color: AppColors.blue5,
                        label: "Wrong",
                        count: wrongAnswers,
                      ),
                      _ScoreLegendItem(
                        color: AppColors.grey4,
                        label: "Skipped",
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
                      _selectedQuestionType,
                      style: AppTextStyles.body.copyWith(color: AppColors.grey12),
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
                      onSelected: (value) {
                        setState(() => _selectedQuestionType = value);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: "Skipped",
                          child: _QuestionTypeMenuItem(
                            icon: Icons.remove,
                            label: "Skipped",
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "Correct",
                          child: _QuestionTypeMenuItem(
                            icon: Icons.check,
                            label: "Correct",
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "Wrong",
                          child: _QuestionTypeMenuItem(
                            icon: Icons.close,
                            label: "Wrong",
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
                    separatorBuilder: (context, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final result = visibleQuestions[index];

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              "${result.questionNumber}.",
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
                        label: "Retake Lesson",
                        width: double.infinity,
                        type: ButtonType.outline,
                        customBorderColor: AppColors.grey5,
                        size: ButtonSize.md,
                        onTap: () => Navigator.of(context).pushReplacementNamed(
                          "/lesson",
                          arguments: widget.lessonId,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Button(
                        label: "Done",
                        width: double.infinity,
                        type: ButtonType.primary,
                        size: ButtonSize.md,
                        customBackgroundColor: AppColors.blue9,
                        customForegroundColor: AppColors.white,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil("/home", (route) => false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionTypeMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuestionTypeMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.grey9),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.body),
      ],
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
            "$label ($count)",
            style: AppTextStyles.body.copyWith(color: AppColors.grey12),
          ),
        ],
      ),
    );
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double correctFraction;
  final double wrongFraction;

  const _ScoreCirclePainter({
    required this.correctFraction,
    required this.wrongFraction,
  });

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
    final correctPaint = Paint()
      ..color = AppColors.blue9
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final wrongPaint = Paint()
      ..color = AppColors.blue5
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, backgroundPaint);

    const startAngle = -math.pi / 2;
    final correctSweep = 2 * math.pi * correctFraction.clamp(0, 1);
    final wrongSweep = 2 * math.pi * wrongFraction.clamp(0, 1);

    canvas.drawArc(rect, startAngle, correctSweep, false, correctPaint);
    canvas.drawArc(
      rect,
      startAngle + correctSweep,
      wrongSweep,
      false,
      wrongPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return correctFraction != oldDelegate.correctFraction ||
        wrongFraction != oldDelegate.wrongFraction;
  }
}

String _formatElapsedTime(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, "0");
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");

  return "$minutes:$seconds";
}
