import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:baybai/core/theme/colors.dart';
import 'package:baybai/core/theme/text.dart';
import 'package:baybai/features/quiz/data/quiz_question_bank.dart';
import 'package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart';
import 'package:baybai/shared/components/buttons/button.dart';

List<int> pickRandomQuestionIndexes(
  int totalCount, {
  int limit = 10,
  int? seed,
}) {
  if (totalCount <= 0) return const [];

  final random = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
  final indexes = List<int>.generate(totalCount, (index) => index);

  if (limit >= totalCount) {
    return indexes..shuffle(random);
  }

  final selected = <int>[];
  while (selected.length < limit) {
    final nextIndex = random.nextInt(totalCount);
    if (!selected.contains(nextIndex)) {
      selected.add(nextIndex);
    }
  }

  return selected;
}

List<String> shuffleAnswerKeys(List<String> keys, {int? seed}) {
  final shuffled = [...keys];
  final random = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
  shuffled.shuffle(random);
  return shuffled;
}

int questionLimitForSelection(String selection) {
  switch (selection) {
    case 'Fewer':
      return 5;
    case 'More':
      return 15;
    case 'Standard':
    default:
      return 10;
  }
}

int quizDurationInSeconds(String selection) {
  switch (selection) {
    case '5 min':
      return 5 * 60;
    case '8 min':
      return 8 * 60;
    case 'No limit':
    default:
      return 0;
  }
}

String timeLimitDisplay(String selection) {
  final totalSeconds = quizDurationInSeconds(selection);
  if (totalSeconds <= 0) {
    return '-- : --';
  }

  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String elapsedTimeDisplay(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class QuizSetupPage extends StatefulWidget {
  final int questionLimit;
  final String timeLimit;
  final String difficulty;

  const QuizSetupPage({
    super.key,
    this.questionLimit = 10,
    this.timeLimit = 'No limit',
    this.difficulty = 'Easy',
  });

  @override
  State<QuizSetupPage> createState() => _QuizSetupPageState();
}

class _QuizSetupPageState extends State<QuizSetupPage> {
  static const double _baybayinFontSize = 28;
  static const double _answerBaybayinFontSize = 22;

  static const List<String> _answerKeys = ['A', 'B', 'C', 'D'];

  int _currentQuestionIndex = 0;
  Timer? _timer;
  late Duration _remainingTime;
  Duration _elapsedTime = Duration.zero;
  bool _hasFinished = false;

  late final List<QuizQuestion> _questions;
  late final List<List<String>> _shuffledAnswerKeysByQuestion;
  final List<String?> _selectedAnswersByQuestion = <String?>[];

  @override
  void initState() {
    super.initState();

    final difficultyQuestions = quizQuestionBank
        .where((question) => question.difficulty == widget.difficulty)
        .toList(growable: false);
    final randomizedIndexes = pickRandomQuestionIndexes(
      difficultyQuestions.length,
      limit: widget.questionLimit,
    );

    _questions = randomizedIndexes
        .map((index) => difficultyQuestions[index])
        .toList(growable: false);

    _shuffledAnswerKeysByQuestion = _questions
        .map((_) => shuffleAnswerKeys(_answerKeys))
        .toList(growable: false);
    _selectedAnswersByQuestion
      ..clear()
      ..addAll(List<String?>.filled(_questions.length, null));

    _remainingTime = Duration(seconds: quizDurationInSeconds(widget.timeLimit));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      var timeExpired = false;
      setState(() {
        _elapsedTime += const Duration(seconds: 1);
        if (widget.timeLimit != 'No limit' && _remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          timeExpired = _remainingTime.inSeconds == 0;
        } else if (widget.timeLimit != 'No limit') {
          timeExpired = true;
        }
      });

      if (timeExpired) {
        timer.cancel();
        _finishQuiz();
      }
    });
  }

  String _timerText() {
    if (widget.timeLimit == 'No limit') {
      return '-- : --';
    }

    final totalSeconds = _remainingTime.inSeconds;
    if (totalSeconds <= 0) {
      return '00:00';
    }

    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  QuizQuestion get currentQuestion => _questions[_currentQuestionIndex];

  List<String> get currentAnswerKeys =>
      _shuffledAnswerKeysByQuestion[_currentQuestionIndex];

  String? get selectedAnswer =>
      _selectedAnswersByQuestion[_currentQuestionIndex];

  List<String> get shuffledOptionTexts {
    final answerMap = {
      for (var i = 0; i < _answerKeys.length; i++)
        _answerKeys[i]: currentQuestion.options[i],
    };

    return currentAnswerKeys
        .map((key) => answerMap[key] ?? '')
        .toList(growable: false);
  }

  void _goToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex += 1;
      }
    });
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex -= 1;
      }
    });
  }

  void _finishQuiz() {
    if (_hasFinished) return;
    _hasFinished = true;
    _timer?.cancel();

    final correctAnswers = _selectedAnswersByQuestion
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.value != null &&
              entry.value == _questions[entry.key].answer,
        )
        .length;
    final skippedAnswers = _selectedAnswersByQuestion
        .where((answer) => answer == null)
        .length;
    final questionResults = List<_QuizQuestionResult>.generate(
      _questions.length,
      (index) {
        final selectedAnswer = _selectedAnswersByQuestion[index];
        final status = selectedAnswer == null
            ? 'Skipped'
            : selectedAnswer == _questions[index].answer
            ? 'Correct'
            : 'Wrong';
        return _QuizQuestionResult(
          questionNumber: index + 1,
          question: _questions[index].question,
          status: status,
        );
      },
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizCompletePage(
          correctAnswers: correctAnswers,
          totalQuestions: _questions.length,
          skippedAnswers: skippedAnswers,
          elapsedTime: _elapsedTime,
          questionResults: questionResults,
          questionLimit: widget.questionLimit,
          timeLimit: widget.timeLimit,
          difficulty: widget.difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final questionNumber = _currentQuestionIndex + 1;
    final optionTexts = shuffledOptionTexts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Center(child: CustomBackButton()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$questionNumber/${_questions.length}',
                    style: AppTextStyles.body.copyWith(color: AppColors.gray80),
                  ),
                  if (widget.timeLimit != 'No limit')
                    Text(
                      _timerText(),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray80,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _baybayinText(
                currentQuestion.question,
                AppTextStyles.bigbody.copyWith(
                  color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < currentAnswerKeys.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == currentAnswerKeys.length - 1 ? 0 : 8,
                  ),
                  child: _answerButton(
                    label: _answerKeys[i],
                    text: optionTexts[i],
                    isCorrect: currentQuestion.answer == currentAnswerKeys[i],
                    isSelected: selectedAnswer == currentAnswerKeys[i],
                    isAnswerRevealed: selectedAnswer != null,
                    isDisabled: selectedAnswer != null,
                    onTap: () => setState(
                      () => _selectedAnswersByQuestion[_currentQuestionIndex] =
                          currentAnswerKeys[i],
                    ),
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _currentQuestionIndex > 0
                        ? Button(
                            label: 'Previous',
                            width: double.infinity,
                            onTap: _goToPreviousQuestion,
                            type: ButtonType.outline,
                            customBorderColor: AppColors.gray20,
                            size: ButtonSize.md,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Button(
                      label: _currentQuestionIndex == _questions.length - 1
                          ? 'Done'
                          : 'Next',
                      width: double.infinity,
                      onTap: _currentQuestionIndex == _questions.length - 1
                          ? _finishQuiz
                          : _goToNextQuestion,
                      type: ButtonType.primary,
                      size: ButtonSize.md,
                      customBackgroundColor: AppColors.primary60,
                      customForegroundColor: AppColors.bg,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _baybayinText(
    String text,
    TextStyle style, {
    double baybayinFontSize = _baybayinFontSize,
  }) {
    final baybayinFontWeight =
        AppTextStyles.bigbody.fontWeight ?? FontWeight.normal;

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final rune in text.runes)
            TextSpan(
              text: String.fromCharCode(rune),
              style: rune >= 0x1700 && rune <= 0x171F
                  ? TextStyle(
                      fontSize: baybayinFontSize,
                      fontWeight: baybayinFontWeight,
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _answerButton({
    required String label,
    required String text,
    required bool isCorrect,
    required bool isSelected,
    required bool isAnswerRevealed,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    final bool showCorrectState = isAnswerRevealed && isCorrect;
    final bool showCorrectFeedback = isSelected && isCorrect;
    final bool showWrongState = isSelected && !isCorrect;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: AppColors.gray100,
          backgroundColor: showCorrectState
              ? AppColors.bgSuccess
              : showWrongState
              ? AppColors.bgError
              : AppColors.gray20,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$label.',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _baybayinText(
                text,
                AppTextStyles.body,
                baybayinFontSize: _answerBaybayinFontSize,
              ),
            ),
            if (showCorrectState)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: Color(0xFF0B5F3C), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    showCorrectFeedback ? 'That\'s right!' : 'Correct Answer',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.bgSuccessContrast,
                    ),
                  ),
                ],
              ),
            if (showWrongState)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: Color(0xFFB42318), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Not Quite!',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.bgErrorContrast,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class QuizCompletePage extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int skippedAnswers;
  final Duration elapsedTime;
  final List<_QuizQuestionResult> questionResults;
  final int questionLimit;
  final String timeLimit;
  final String difficulty;

  const QuizCompletePage({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.skippedAnswers,
    required this.elapsedTime,
    required this.questionResults,
    required this.questionLimit,
    required this.timeLimit,
    required this.difficulty,
  });

  @override
  State<QuizCompletePage> createState() => _QuizCompletePageState();
}

class _QuizCompletePageState extends State<QuizCompletePage> {
  String selectedQuestionType = 'Skipped';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.gray100 : AppColors.gray10;
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
                    'Your Score',
                    style: AppTextStyles.body.copyWith(color: AppColors.gray80),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.correctAnswers}/${widget.totalQuestions}',
                        style: AppTextStyles.bigbody,
                      ),
                      Text(
                        elapsedTimeDisplay(widget.elapsedTime),
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
                                color: AppColors.gray90,
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
                          label: 'Correct',
                          count: widget.correctAnswers,
                        ),
                        _ScoreLegendItem(
                          color: AppColors.primary40,
                          label: 'Wrong',
                          count: wrongAnswers,
                        ),
                        _ScoreLegendItem(
                          color: AppColors.gray30,
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
                    color: AppColors.gray40,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        selectedQuestionType,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray100,
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
                        color: AppColors.gray10,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: AppColors.gray20),
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
                                  color: AppColors.gray70,
                                ),
                                const SizedBox(width: 12),
                                Text('Skipped', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Correct',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: AppColors.gray70,
                                ),
                                const SizedBox(width: 12),
                                Text('Correct', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Wrong',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.close,
                                  color: AppColors.gray70,
                                ),
                                const SizedBox(width: 12),
                                Text('Wrong', style: AppTextStyles.body),
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
                                  color: AppColors.gray100,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.question,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.gray100,
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
                          label: 'Retake Quiz',
                          width: double.infinity,
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => QuizSetupPage(
                                questionLimit: widget.questionLimit,
                                timeLimit: widget.timeLimit,
                                difficulty: widget.difficulty,
                              ),
                            ),
                          ),
                          type: ButtonType.outline,
                          customBorderColor: AppColors.gray40,
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
                          customBackgroundColor: AppColors.primary60,
                          customForegroundColor: AppColors.bg,
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
        color: AppColors.gray20,
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
            style: AppTextStyles.body.copyWith(color: AppColors.gray100),
          ),
        ],
      ),
    );
  }
}

class _QuizQuestionResult {
  final int? questionNumber;
  final String question;
  final String status;

  const _QuizQuestionResult({
    required this.questionNumber,
    required this.question,
    required this.status,
  });
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
      ..color = AppColors.gray30
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final blue9Paint = Paint()
      ..color = AppColors.primary60
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final blue5Paint = Paint()
      ..color = AppColors.primary40
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
