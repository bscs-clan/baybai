import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hugeicons/hugeicons.dart";
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
  final List<LessonQuestionResult> questionResults;

  const LessonCompletePage({
    super.key,
    required this.lessonId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questionResults,
  });

  @override
  State<LessonCompletePage> createState() => _LessonCompletePageState();
}

class _LessonCompletePageState extends State<LessonCompletePage> {
  String _selectedQuestionType = "Correct";
  final ScrollController _questionListController = ScrollController();

  @override
  void dispose() {
    _questionListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final performanceTextColor =
        isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final wrongAnswers = widget.totalQuestions - widget.correctAnswers;
    final scorePercentage = widget.totalQuestions == 0
        ? 0
        : ((widget.correctAnswers / widget.totalQuestions) * 100).round();
    final visibleQuestions = widget.questionResults
        .where((result) => result.status == _selectedQuestionType)
        .toList(growable: false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.bg,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: isDarkMode ? AppColors.gray100 : AppColors.bg,
          body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Score",
                  style: AppTextStyles.regularSm.copyWith(
                    color: AppColors.gray60,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    HugeIcon(
                      icon: widget.correctAnswers == 0
                          ? HugeIcons.strokeRoundedCancel01
                          : HugeIcons.strokeRoundedParty,
                      size: 24,
                      color: performanceTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _performanceMessage(
                          correctAnswers: widget.correctAnswers,
                          totalQuestions: widget.totalQuestions,
                        ),
                        style: AppTextStyles.boldLg.copyWith(
                          color: performanceTextColor,
                        ),
                      ),
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
                            style: AppTextStyles.boldXl.copyWith(
                              color: AppColors.gray100,
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
                        color: AppColors.primary60,
                        label: "Correct",
                        count: widget.correctAnswers,
                      ),
                      _ScoreLegendItem(
                        color: AppColors.primary30,
                        label: "Wrong",
                        count: wrongAnswers,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, thickness: 1, color: AppColors.gray20),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      _selectedQuestionType,
                      style: AppTextStyles.regularSm.copyWith(
                        color: AppColors.gray100,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        size: 24,
                        color: isDarkMode
                            ? AppColors.gray10
                            : AppColors.gray100,
                      ),
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      color: AppColors.bg,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppColors.gray20),
                      ),
                      onSelected: (value) {
                        setState(() => _selectedQuestionType = value);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: "Correct",
                          child: _QuestionTypeMenuItem(
                            icon: HugeIcons.strokeRoundedTick01,
                            label: "Correct",
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: "Wrong",
                          child: _QuestionTypeMenuItem(
                            icon: HugeIcons.strokeRoundedCancel01,
                            label: "Wrong",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 160,
                  child: Scrollbar(
                    controller: _questionListController,
                    thumbVisibility: true,
                    interactive: true,
                    child: ListView.separated(
                      controller: _questionListController,
                      padding: const EdgeInsets.only(right: 8),
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
                              "${result.questionNumber}.",
                              style: AppTextStyles.regularSm.copyWith(
                                color: AppColors.gray100,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.question,
                              style: AppTextStyles.regularSm.copyWith(
                                color: AppColors.gray100,
                              ),
                            ),
                          ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    label: "Try Again",
                    width: double.infinity,
                    type: ButtonType.outline,
                    customBorderColor: AppColors.gray20,
                    size: ButtonSize.md,
                    textStyle: AppTextStyles.boldSm,
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
                    textStyle: AppTextStyles.boldSm,
                    customBackgroundColor: AppColors.primary60,
                    customForegroundColor: AppColors.bg,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil("/home", (route) => false),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  String _performanceMessage({
    required int correctAnswers,
    required int totalQuestions,
  }) {
    if (totalQuestions == 0 || correctAnswers == 0) {
      return "Better try next time";
    }

    final accuracy = correctAnswers / totalQuestions;
    if (accuracy == 1) return "Awesome";
    if (accuracy >= 0.75) return "Great job";
    if (accuracy >= 0.5) return "Nice";
    return "Good try";
  }
}

class _QuestionTypeMenuItem extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;

  const _QuestionTypeMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HugeIcon(icon: icon, color: AppColors.gray50, size: 24),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.regularSm),
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
        color: AppColors.gray10,
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
            style: AppTextStyles.regularSm.copyWith(color: AppColors.gray100),
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
      ..color = AppColors.gray20
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final correctPaint = Paint()
      ..color = AppColors.primary60
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final wrongPaint = Paint()
      ..color = AppColors.primary30
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
