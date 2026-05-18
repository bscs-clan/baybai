import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_navigation_bar.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_slide.dart";

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

    setState(() {
      _isLoading = false;
    });
  }

  void _nextPage() async {
    if (_currentIndex < _lessons.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('lesson_${_lessonId}_completed', true);
      await prefs.setInt('lesson_${_lessonId}_progress', _lessons.length);
      
      int currentUnlocked = prefs.getInt('unlocked_lessons') ?? 1;
      if (currentUnlocked <= _lessonId) {
        await prefs.setInt('unlocked_lessons', _lessonId + 1);
      }

      if (mounted) {
        Navigator.pop(context);
      }
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
                onPageChanged: (index) async {
                  setState(() {
                    _currentIndex = index;
                    _isQuestionAnswered = false; // Reset for the next slide
                  });
                  final prefs = await SharedPreferences.getInstance();
                  bool isCompleted = prefs.getBool('lesson_${_lessonId}_completed') ?? false;
                  if (!isCompleted) {
                    await prefs.setInt('lesson_${_lessonId}_progress', index);
                  }
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
