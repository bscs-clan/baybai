import "package:flutter/material.dart";
import "package:baybai/presentation/lessons/models/lesson_content.dart";
import "package:baybai/presentation/lessons/widgets/lesson_slide.dart";
import "package:baybai/presentation/lessons/widgets/lesson_back_button.dart";
import "package:baybai/presentation/lessons/widgets/lesson_navigation_bar.dart";

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isQuestionAnswered = false;

  final List<LessonContent> _lessons = [
    LessonContent(
      title: "What is Baybayin?",
      description:
          "Baybayin is an ancient Filipino writing system. Each symbol represents a **sound**, not just a letter. Lets start with the basic sounds.",
      image: "assets/images/lesson1_image1.png",
    ),
    LessonContent(
      title: "First Vowel",
      description:
          "It is the first vowel symbol in Baybayin. It is read as **'A'**.",
      image: "assets/images/lesson1_image2.png",
    ),
    LessonContent(
      title: "Second Vowel",
      description: "It makes the sound **'I' or 'E'** , Depending on the word",
      image: "assets/images/lesson1_image3.png",
    ),
    LessonContent(
      title: "Third Vowel",
      description:
          "The last vowel of symbol of Baybayin. It is read as **'O' or 'U'** ",
      image: "assets/images/lesson1_image4.png",
    ),
    LessonContent(
      title: "Quick Check",
      description: "Which one is **'A'**?",
      image: "assets/images/lesson1_image5.png",
      imageHeight: 200,
      imageFit: BoxFit.contain,
      options: ["\u1700", "\u1701", "\u1702"],
      correctOption: "\u1700",
    ),
    LessonContent(
      title: "First Consonant",
      description:
          "It makes the sound **'BA'**. In Baybayin, consonant already include the 'A' sound.",
      image: "assets/images/lesson1_image6.png",
    ),
    LessonContent(
      title: "More Consonants",
      description:
          "These are some consonants symbols in Baybayin. Each one already includes the **'A'** sound, so you read them as KA,MA, and BA.",
      image: "assets/images/lesson1_image7.png",
      imageFit: BoxFit.contain,
    ),
    LessonContent(
      title: "Quick Practice",
      description: "Which one is **'MA'**?",
      image: "assets/images/lesson1_image5.png",
      imageHeight: 200,
      imageFit: BoxFit.contain,
      options: ["\u170A", "\u1703", "\u170B"],
      correctOption: "\u170B",
    ),
    LessonContent(
      title: "Congratulations",
      description:
          "You've completed the lesson. You learned about the vowels, Basic Sound. Next you'll learn how to change sound using marks",
      image: "assets/images/lesson1_image8.png",
      imageFit: BoxFit.contain,
      iconPath: "assets/icons/confetti.svg",
    ),
  ];

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
