import "package:flutter/material.dart";
import "package:baybai/presentation/lessons/models/lesson_content.dart";
import "package:baybai/presentation/lessons/widgets/lesson_slide.dart";
import "package:baybai/presentation/lessons/widgets/lesson_back_button.dart";
import "package:baybai/presentation/lessons/widgets/lesson_navigation_bar.dart";
import "package:baybai/presentation/lessons/data/lesson_data.dart";

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isQuestionAnswered = false;
  late List<LessonContent> _lessons;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      final int lessonId = ModalRoute.of(context)!.settings.arguments as int? ?? 1;
      _lessons = LessonData.lessons[lessonId] ?? LessonData.lessons[1]!;
      _isLoading = false;
    }
  }

  void _nextPage() {
    if (_currentIndex < _lessons.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
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
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _isQuestionAnswered = false; // Reset for the next slide
                  });
                },
                itemCount: _lessons.length,
                itemBuilder: (context, index) => LessonSlide(
                  lesson: _lessons[index],
                  onAnswered: (answered) {
                    setState(() {
                      _isQuestionAnswered = answered;
                    });
                  },
                ),
              ),
            ),
            LessonNavigationBar(
              currentIndex: _currentIndex,
              totalLessons: _lessons.length,
              onPrevious: canNavigate ? _previousPage : null,
              onNext: canNavigate ? _nextPage : null,
            ),
          ],
        ),
      ),
    );
  }
}
