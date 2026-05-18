import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/features/home/presentation/widgets/explore_section.dart";
import "package:baybai/features/home/presentation/widgets/learn_card.dart";
import "package:baybai/features/home/presentation/widgets/learn_header.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";

class TabLearn extends StatefulWidget {
  const TabLearn({super.key});

  @override
  State<TabLearn> createState() => _TabLearnState();
}

class _TabLearnState extends State<TabLearn> {
  int _unlockedLessons = 1;
  Map<int, int> _progress = {};
  Map<int, bool> _completed = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load unlocked lessons count, default to 1
    final unlocked = prefs.getInt('unlocked_lessons') ?? 1;
    
    // Load progress and completion for all lessons
    final progress = <int, int>{};
    final completed = <int, bool>{};
    
    for (int i = 1; i <= LessonData.lessons.length; i++) {
      progress[i] = prefs.getInt('lesson_${i}_progress') ?? 0;
      completed[i] = prefs.getBool('lesson_${i}_completed') ?? false;
    }
    
    setState(() {
      _unlockedLessons = unlocked;
      _progress = progress;
      _completed = completed;
      _isLoading = false;
    });
  }

  void _navigateToLesson(int lessonId) async {
    await Navigator.pushNamed(
      context,
      "/lesson",
      arguments: lessonId,
    );
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LearnHeader(userName: "Deobert"),
            const SizedBox(height: 24),
            LearnCard(
              lessonNumber: "Lesson 1",
              title: "Baybayin Basics",
              lessonId: 1,
              isLocked: _unlockedLessons < 1,
              currentPage: _progress[1] ?? 0,
              totalPages: LessonData.lessons[1]?.length ?? 1,
              isCompleted: _completed[1] ?? false,
              onTap: () => _navigateToLesson(1),
            ),
            const SizedBox(height: 16),
            LearnCard(
              lessonNumber: "Lesson 2",
              title: "Understanding Sounds",
              lessonId: 2,
              isLocked: _unlockedLessons < 2,
              currentPage: _progress[2] ?? 0,
              totalPages: LessonData.lessons[2]?.length ?? 1,
              isCompleted: _completed[2] ?? false,
              onTap: () => _navigateToLesson(2),
            ),
            const SizedBox(height: 16),
            LearnCard(
              lessonNumber: "Lesson 3",
              title: "The Kudlit Mark",
              lessonId: 3,
              isLocked: _unlockedLessons < 3,
              currentPage: _progress[3] ?? 0,
              totalPages: LessonData.lessons[3]?.length ?? 1,
              isCompleted: _completed[3] ?? false,
              onTap: () => _navigateToLesson(3),
            ),
            const SizedBox(height: 32),
            const ExploreSection(),
          ],
        ),
      ),
    );
  }
}
