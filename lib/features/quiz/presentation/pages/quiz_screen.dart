import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/quiz/domain/entities/quiz_question.dart";
import "package:baybai/features/quiz/presentation/widgets/difficulty_card.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "dart:async";

class QuizScreen extends StatefulWidget {
  final QuizModeInfo mode;

  const QuizScreen({super.key, required this.mode});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedOption;

  Timer? _timer;
  double _timerValue = 1.0;
  static const int _totalTime = 30;

  @override
  void initState() {
    super.initState();
    if (widget.mode.hasTimer) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerValue = 1.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        _timerValue -= 0.1 / _totalTime;

        if (_timerValue <= 0) {
          _timerValue = 0;
          _timer?.cancel();
          _handleAnswer(null);
        }
      });
    });
  }

  String _formatTime() {
    int seconds = (_timerValue * _totalTime).ceil();
    return "00:${seconds.toString().padLeft(2, '0')}";
  }

  void _showHintDialog() {
    final question = sampleQuestions[_currentQuestionIndex];

    showDialog(
      context: context,
      builder: (context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: ShapeDecoration(
              color: isDarkMode ? AppColors.darkBox : AppColors.box,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SolarIcon(AppSolarIcons.lightbulb, size: 60, color: AppColors.primary),
                const SizedBox(height: 20),

                Text(
                  "Hint",
                  style: AppTextStyles.bigbody.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.text,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  question.hint,
                  style: AppTextStyles.body.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextGrey
                        : AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                Button(label: "Got it", onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAnswer(String? option) {
    if (_isAnswered) return;

    _timer?.cancel();

    setState(() {
      _isAnswered = true;
      _selectedOption = option;

      if (option == sampleQuestions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (!_isAnswered) return;

    if (_currentQuestionIndex < sampleQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedOption = null;
      });

      if (widget.mode.hasTimer) {
        _startTimer();
      }
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: ShapeDecoration(
              color: isDarkMode ? AppColors.darkBox : AppColors.box,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(38),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SolarIcon(AppSolarIcons.cupStar, size: 60, color: AppColors.primary),
                const SizedBox(height: 20),

                Text(
                  "Quiz Completed!",
                  style: AppTextStyles.bigbody.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.text,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Score: $_score / ${sampleQuestions.length}",
                  style: AppTextStyles.body.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextGrey
                        : AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 30),

                Button(
                  label: "Continue",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final question = sampleQuestions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  GestureDetector(
                    onTap: widget.mode.hasHints ? _showHintDialog : null,
                    child: Opacity(
                      opacity: widget.mode.hasHints ? 1.0 : 0.5,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: isDarkMode ? AppColors.darkBox : AppColors.box,
                          shape: RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SolarIcon(AppSolarIcons.lightbulb, size: 24, color: isDarkMode ? AppColors.darkIcon : AppColors.icon),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentQuestionIndex + 1}/${sampleQuestions.length}",
                    style: AppTextStyles.body.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.mode.hasTimer ? _formatTime() : "--:--",
                    style: AppTextStyles.body.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What is this symbol?",
                    style: AppTextStyles.bigbody.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 250,
                    child: Center(
                      child: Image.asset(
                        question.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        bool isSelected = _selectedOption == option;
                        bool isCorrect = option == question.correctAnswer;

                        Color borderColor = Colors.transparent;

                        if (_isAnswered) {
                          if (isCorrect) {
                            borderColor = Colors.green;
                          } else if (isSelected) {
                            borderColor = Colors.red;
                          }
                        } else if (isSelected) {
                          borderColor = AppColors.primary;
                        }

                        return GestureDetector(
                          onTap: () => _handleAnswer(option),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: isDarkMode
                                  ? AppColors.darkBox
                                  : AppColors.box,
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: borderColor, width: 2),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    option,
                                    style: AppTextStyles.body.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkText
                                          : AppColors.text,
                                    ),
                                  ),
                                ),
                                if (_isAnswered)
                                  if (isCorrect)
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    )
                                  else if (isSelected)
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Button(
                label: "Next",
                width: double.infinity,
                onTap: _isAnswered ? _nextQuestion : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
