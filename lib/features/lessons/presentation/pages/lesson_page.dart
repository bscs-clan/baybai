import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/data/datasources/lesson_progress.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_navigation_bar.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_slide.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_progress_bar.dart";
import "package:baybai/features/lessons/presentation/pages/lesson_complete_page.dart";

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final PageController _pageController;
  int _currentIndex = 0;
  late final List<LessonContent> _lessons;
  late final int _lessonId;
  bool _isInitialized = false;

  final Map<int, String> _userAnswers = {};
  final Map<int, String?> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    _lessonId = (args is int && LessonData.lessons.containsKey(args))
        ? args
        : 1;
    _lessons = LessonData.lessons[_lessonId] ?? LessonData.lessons[1]!;
    _isInitialized = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentIndex < _lessons.length - 1) {
      _pageController.jumpToPage(_currentIndex + 1);
    } else {
      await LessonProgress.markCompleted(_lessonId);
      if (!mounted) return;
      final questionResults = _buildQuestionResults();
      final correctAnswers = questionResults
          .where((result) => result.status == "Correct")
          .length;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompletePage(
            lessonId: _lessonId,
            correctAnswers: correctAnswers,
            totalQuestions: questionResults.length,
            questionResults: questionResults,
          ),
        ),
      );
    }
  }

  List<LessonQuestionResult> _buildQuestionResults() {
    final results = <LessonQuestionResult>[];

    for (var index = 0; index < _lessons.length; index++) {
      final lesson = _lessons[index];
      final hasOptions = lesson.options != null && lesson.options!.isNotEmpty;
      if (!hasOptions && !lesson.showTextInput) continue;

      final selectedOption = _selectedOptions[index];
      final isCorrect = lesson.showTextInput
          ? selectedOption?.trim().toLowerCase() ==
                lesson.correctOption?.trim().toLowerCase()
          : selectedOption == lesson.correctOption;
      final status = isCorrect ? "Correct" : "Wrong";

      results.add(
        LessonQuestionResult(
          questionNumber: results.length + 1,
          question:
              lesson.title ??
              lesson.wordCardText ??
              "Question ${results.length + 1}",
          status: status,
        ),
      );
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentLesson = _lessons[_currentIndex];
    final hasOptions =
        (currentLesson.options != null && currentLesson.options!.isNotEmpty) ||
        currentLesson.showTextInput;

    String? customNextLabel;
    bool showNextIcon = true;
    VoidCallback? onNextAction;
    Color? customNextBackgroundColor;
    Color? customNextForegroundColor;
    String? feedbackLabel;
    Color? feedbackColor;
    Color? navigationBackgroundColor;

    if (hasOptions) {
      final hasChecked = _userAnswers.containsKey(_currentIndex);
      final selectedOption = _selectedOptions[_currentIndex];
      showNextIcon = false;

      if (!hasChecked) {
        customNextLabel = "Check";
        if (selectedOption != null && selectedOption.trim().isNotEmpty) {
          onNextAction = () {
            setState(() {
              _userAnswers[_currentIndex] = selectedOption;
            });
          };
        } else {
          onNextAction = null;
        }
      } else {
        customNextLabel = _currentIndex == _lessons.length - 1
            ? "Finish"
            : "Continue";
        onNextAction = _nextPage;
        final isCorrect = currentLesson.showTextInput
            ? selectedOption?.trim().toLowerCase() ==
                  currentLesson.correctOption?.trim().toLowerCase()
            : selectedOption == currentLesson.correctOption;
        feedbackLabel = isCorrect ? "That's right" : "Not quite";
        feedbackColor = isCorrect
            ? AppColors.bgSuccessContrast
            : AppColors.bgErrorContrast;
        navigationBackgroundColor = isCorrect
            ? AppColors.bgSuccess
            : AppColors.bgError;
        customNextBackgroundColor = isCorrect
            ? AppColors.bgSuccessContrast
            : AppColors.bgErrorContrast;
        customNextForegroundColor = AppColors.bg;
      }
    } else {
      onNextAction = _nextPage;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor:
            navigationBackgroundColor ??
            (isDarkMode ? AppColors.gray100 : AppColors.bg),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LessonProgressBar(
                          currentIndex: _currentIndex,
                          totalLessons: _lessons.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    return LessonSlide(
                      key: ValueKey('lesson-slide-$index'),
                      lesson: _lessons[index],
                      lessonId: _lessonId,
                      selectedOption: _selectedOptions[index],
                      hasChecked: _userAnswers.containsKey(index),
                      onOptionSelected: (option) {
                        setState(() {
                          _selectedOptions[index] = option;
                        });
                      },
                    );
                  },
                ),
              ),
              LessonNavigationBar(
                currentIndex: _currentIndex,
                totalLessons: _lessons.length,
                onNext: onNextAction,
                customNextLabel: customNextLabel,
                showNextIcon: showNextIcon,
                customNextBackgroundColor: customNextBackgroundColor,
                customNextForegroundColor: customNextForegroundColor,
                feedbackLabel: feedbackLabel,
                feedbackColor: feedbackColor,
                navigationBackgroundColor: navigationBackgroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
