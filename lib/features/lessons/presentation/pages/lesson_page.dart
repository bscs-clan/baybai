import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";

import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
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
  late final DateTime _startedAt;
  bool _isInitialized = false;

  final Map<int, String> _userAnswers = {};
  final Map<int, String?> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _startedAt = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    _lessonId = (args is int && LessonData.lessons.containsKey(args)) ? args : 1;
    _lessons = LessonData.lessons[_lessonId] ?? LessonData.lessons[1]!;
    _isInitialized = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _lessons.length - 1) {
      _pageController.jumpToPage(_currentIndex + 1);
    } else {
      final questionResults = _buildQuestionResults();
      final correctAnswers = questionResults
          .where((result) => result.status == "Correct")
          .length;
      final skippedAnswers = questionResults
          .where((result) => result.status == "Skipped")
          .length;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompletePage(
            lessonId: _lessonId,
            correctAnswers: correctAnswers,
            totalQuestions: questionResults.length,
            skippedAnswers: skippedAnswers,
            elapsedTime: DateTime.now().difference(_startedAt),
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
      if (lesson.options == null || lesson.options!.isEmpty) continue;

      final selectedOption = _selectedOptions[index];
      final status = selectedOption == null
          ? "Skipped"
          : selectedOption == lesson.correctOption
          ? "Correct"
          : "Wrong";

      results.add(
        LessonQuestionResult(
          questionNumber: results.length + 1,
          question: lesson.title,
          status: status,
        ),
      );
    }

    return results;
  }


  @override
  Widget build(BuildContext context) {
    final currentLesson = _lessons[_currentIndex];
    final hasOptions =
        currentLesson.options != null && currentLesson.options!.isNotEmpty;

    String? customNextLabel;
    bool showNextIcon = true;
    VoidCallback? onNextAction;
    Color? customNextBackgroundColor;
    Color? customNextForegroundColor;

    if (hasOptions) {
      final hasChecked = _userAnswers.containsKey(_currentIndex);
      final selectedOption = _selectedOptions[_currentIndex];
      showNextIcon = false;

      if (!hasChecked) {
        customNextLabel = "Check";
        if (selectedOption != null) {
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
        final isCorrect = selectedOption == currentLesson.correctOption;
        customNextBackgroundColor = isCorrect
            ? Colors.green.shade600
            : Colors.red.shade600;
        customNextForegroundColor = AppColors.white;
      }
    } else {
      onNextAction = _nextPage;
    }

    return Scaffold(
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
            ),
          ],
        ),
      ),
    );
  }
}
