import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_navigation_bar.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_slide.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_complete_widget.dart";

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isQuestionAnswered = false;
  late List<LessonContent> _lessons;
  bool _isLoading = true;
  late int _lessonId;

  late DateTime _startTime;
  final Map<int, String> _userAnswers = {};
  Duration? _lessonDuration;
  bool _isNextLessonUnlocked = false;
  List<LessonContent>? _retrySlides;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _lessonId = ModalRoute.of(context)!.settings.arguments as int? ?? 1;
      _lessons = LessonData.lessons[_lessonId] ?? LessonData.lessons[1]!;
      _initLesson();
    }
  }

  Future<void> _initLesson() async {
    final prefs = await SharedPreferences.getInstance();

    bool isCompleted = prefs.getBool('lesson_${_lessonId}_completed') ?? false;

    if (isCompleted) {
      _currentIndex = 0;
    } else {
      _currentIndex = prefs.getInt('lesson_${_lessonId}_progress') ?? 0;
    }

    if (_currentIndex >= _lessons.length) {
      _currentIndex = 0;
    }

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
    await prefs.setInt('lesson_${_lessonId}_progress', _lessons.length);

    int currentUnlocked = prefs.getInt('unlocked_lessons') ?? 1;
    if (currentUnlocked <= _lessonId) {
      await prefs.setInt('unlocked_lessons', _lessonId + 1);
      _isNextLessonUnlocked = true;
    } else {
      _isNextLessonUnlocked = true;
    }
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
    // Build a fresh lesson list from only the wrong-answer slides
    final retrySlides = wrongAnswers.map((w) => w.question).toList();
    // Append a completion slide (last slide of the original lesson)
    final completionSlide = _lessons.last;
    retrySlides.add(completionSlide);

    setState(() {
      _retrySlides = retrySlides;
      _lessons = retrySlides;
      _userAnswers.clear();
      _lessonDuration = null;
      _startTime = DateTime.now();
      _currentIndex = 0;
      _isQuestionAnswered = false;
      _isNextLessonUnlocked = false;
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

    final currentLesson = _lessons[_currentIndex];
    final bool isQuiz =
        currentLesson.options != null && currentLesson.options!.isNotEmpty;
    final bool canNavigate = !isQuiz || _isQuestionAnswered;

    // Calculate statistics
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
            wrongAnswers.add(WrongAnswerInfo(
              question: lesson,
              selectedOption: userAnswer,
              correctOption: lesson.correctOption ?? '',
            ));
          }
        }
      }
    }

    final duration = _lessonDuration ?? DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final formattedTime = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomBackButton(),
                const SizedBox(width: 16),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: (_currentIndex + 1) / _lessons.length,
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) async {
                  setState(() {
                    _currentIndex = index;
                    _isQuestionAnswered = false; // Reset for the next slide
                  });
                  if (index == _lessons.length - 1) {
                    await _handleLessonCompletion();
                  } else {
                    final prefs = await SharedPreferences.getInstance();
                    bool isCompleted =
                        prefs.getBool('lesson_${_lessonId}_completed') ?? false;
                    if (!isCompleted) {
                      await prefs.setInt('lesson_${_lessonId}_progress', index);
                    }
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
                    lesson: _lessons[index],
                    onAnswered: (answered, {selectedOption}) {
                      setState(() {
                        _isQuestionAnswered = answered;
                        if (selectedOption != null) {
                          _userAnswers[index] = selectedOption;
                        }
                      });
                    },
                  );
                },
              ),
            ),
            LessonNavigationBar(
              currentIndex: _currentIndex,
              totalLessons: _lessons.length,
              onPrevious: (canNavigate && _currentIndex < _lessons.length - 1) ? _previousPage : null,
              onNext: canNavigate ? _nextPage : null,
              onRetry: (_currentIndex == _lessons.length - 1 && wrongAnswers.isNotEmpty)
                  ? () => _retryWrongAnswers(wrongAnswers)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
