import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_navigation_bar.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_slide.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_complete_widget.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_progress_bar.dart";
import "package:baybai/shared/components/toast/toast.dart";

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<LessonContent> _lessons;
  bool _isLoading = true;
  late int _lessonId;

  late DateTime _startTime;
  final Map<int, String> _userAnswers = {};
  final Map<int, String?> _selectedOptions = {};
  Duration? _lessonDuration;
  bool _isNextLessonUnlocked = false;
  int _retryAttempt = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _lessonId = ModalRoute.of(context)!.settings.arguments as int? ?? 1;
      _initLesson();
    }
  }

  int _deriveUnlockedLessons(SharedPreferences prefs) {
    var unlockedLessonId = 1;

    for (final lesson in LessonData.lessonList) {
      if (!LessonData.lessons.containsKey(lesson.id)) {
        continue;
      }

      if (lesson.id != unlockedLessonId) {
        break;
      }

      final isCompleted =
          prefs.getBool('lesson_${lesson.id}_completed') ?? false;
      if (isCompleted) {
        unlockedLessonId = lesson.id + 1;
      } else {
        break;
      }
    }

    return unlockedLessonId;
  }

  Future<void> _initLesson() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLessonId = _deriveUnlockedLessons(prefs);
    await prefs.setInt('unlocked_lessons', unlockedLessonId);

    if (_lessonId > unlockedLessonId ||
        !LessonData.lessons.containsKey(_lessonId)) {
      _lessonId = LessonData.lessons.containsKey(unlockedLessonId)
          ? unlockedLessonId
          : 1;
    }

    _lessons = LessonData.lessons[_lessonId] ?? LessonData.lessons[1]!;
    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
    _startTime = DateTime.now();

    setState(() {
      _isLoading = false;
    });

    if (_currentIndex == _lessons.length - 1) {
      _handleLessonCompletion();
    }
  }

  Future<void> _handleLessonCompletion() async {
    _lessonDuration ??= DateTime.now().difference(_startTime);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lesson_${_lessonId}_completed', true);

    final nextUnlockedLessonId = _deriveUnlockedLessons(prefs);
    await prefs.setInt('unlocked_lessons', nextUnlockedLessonId);
    _isNextLessonUnlocked = nextUnlockedLessonId > _lessonId;
    setState(() {});
  }

  void _nextPage() async {
    if (_currentIndex < _lessons.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _retryWrongAnswers(List<WrongAnswerInfo> wrongAnswers) {
    if (wrongAnswers.isEmpty) return;

    final retrySlides = wrongAnswers
        .map((wrongAnswer) => wrongAnswer.question)
        .where(
          (question) =>
              question.options != null && question.options!.isNotEmpty,
        )
        .toList();

    if (retrySlides.isEmpty) return;

    final completionSlide = _lessons.last;
    retrySlides.add(completionSlide);

    setState(() {
      _lessons = retrySlides;
      _userAnswers.clear();
      _selectedOptions.clear();
      _lessonDuration = null;
      _startTime = DateTime.now();
      _currentIndex = 0;
      _isNextLessonUnlocked = false;
      _retryAttempt++;
    });

    _pageController.jumpToPage(0);
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    int correctCount = 0;
    int incorrectCount = 0;
    int totalQuestions = 0;
    final List<WrongAnswerInfo> wrongAnswers = [];

    for (int i = 0; i < _lessons.length; i++) {
      final lesson = _lessons[i];
      if (lesson.options != null && lesson.options!.isNotEmpty) {
        totalQuestions++;
        final userAnswer = _userAnswers[i];
        if (userAnswer != null) {
          if (userAnswer == lesson.correctOption) {
            correctCount++;
          } else {
            incorrectCount++;
            wrongAnswers.add(
              WrongAnswerInfo(
                question: lesson,
                selectedOption: userAnswer,
                correctOption: lesson.correctOption ?? '',
              ),
            );
          }
        }
      }
    }

    final duration = _lessonDuration ?? DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final formattedTime = minutes > 0
        ? '${minutes}m ${seconds}s'
        : '${seconds}s';

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

            if (mounted) {
              if (selectedOption == currentLesson.correctOption) {
                AppToast.show(
                  context,
                  message: "Correct!",
                  variant: AppToastVariant.success,
                );
              } else {
                AppToast.show(
                  context,
                  message: "Wrong",
                  variant: AppToastVariant.error,
                );
              }
            }
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
                onPageChanged: (index) async {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == _lessons.length - 1) {
                    await _handleLessonCompletion();
                  }
                },
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  if (index == _lessons.length - 1) {
                    return LessonCompleteWidget(
                      lessonId: _lessonId,
                      completionSlide: _lessons[index],
                      correctCount: correctCount,
                      incorrectCount: incorrectCount,
                      totalQuestions: totalQuestions,
                      formattedTime: formattedTime,
                      wrongAnswers: wrongAnswers,
                      isNextLessonUnlocked: _isNextLessonUnlocked,
                    );
                  }
                  return LessonSlide(
                    key: ValueKey('lesson-slide-$_retryAttempt-$index'),
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
              onPrevious: (_currentIndex < _lessons.length - 1)
                  ? _previousPage
                  : null,
              onNext: onNextAction,
              onRetry:
                  (_currentIndex == _lessons.length - 1 &&
                      wrongAnswers.isNotEmpty)
                  ? () => _retryWrongAnswers(wrongAnswers)
                  : null,
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
