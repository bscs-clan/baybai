import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/explore_section.dart";
import "package:baybai/features/home/presentation/widgets/learn_card.dart";
import "package:baybai/features/home/presentation/widgets/learn_header.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class TabLearn extends StatefulWidget {
  const TabLearn({super.key});

  @override
  State<TabLearn> createState() => _TabLearnState();
}

class _TabLearnState extends State<TabLearn> {
  int _unlockedLessons = 1;
  Map<int, bool> _completed = {};
  bool _isLoading = true;

  List<int> get _availableLessonIds => LessonData.lessonList
      .where((lesson) => LessonData.lessons.containsKey(lesson.id))
      .map((lesson) => lesson.id)
      .toList();

  int get _currentLessonId {
    final availableLessonIds = _availableLessonIds;

    for (final lessonId in availableLessonIds) {
      if (lessonId <= _unlockedLessons && !(_completed[lessonId] ?? false)) {
        return lessonId;
      }
    }

    final lastUnlockedLessonId = availableLessonIds.lastWhere(
      (lessonId) => lessonId <= _unlockedLessons,
      orElse: () => availableLessonIds.first,
    );

    return lastUnlockedLessonId;
  }

  LessonMetadata get _currentLesson => LessonData.lessonList.firstWhere(
        (lesson) => lesson.id == _currentLessonId,
        orElse: () => LessonData.lessonList.first,
      );

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Load unlocked lessons count, default to 1
    final unlocked = prefs.getInt('unlocked_lessons') ?? 1;

    // Load completion for all lessons
    final completed = <int, bool>{};

    for (final lesson in LessonData.lessonList) {
      completed[lesson.id] =
          prefs.getBool('lesson_${lesson.id}_completed') ?? false;
    }

    if (!mounted) return;

    setState(() {
      _unlockedLessons = unlocked;
      _completed = completed;
      _isLoading = false;
    });
  }

  void _navigateToLesson(int lessonId) async {
    await Navigator.pushNamed(context, "/lesson", arguments: lessonId);
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentLesson = _currentLesson;
    final currentLessonId = currentLesson.id;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LearnHeader(userName: "Deobert"),
            const SizedBox(height: 24),
            Text(
              "Basic Learning",
              style: AppTextStyles.bigbody.copyWith(
                color: isDarkMode ? AppColors.darkText : AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            LearnCard(
              lessonNumber: currentLesson.number,
              title: currentLesson.title,
              lessonId: currentLessonId,
              isLocked: _unlockedLessons < currentLessonId,
              isCompleted: _completed[currentLessonId] ?? false,
              onTap: () => _navigateToLesson(currentLessonId),
            ),
            const SizedBox(height: 32),
            const ExploreSection(),
          ],
        ),
      ),
    );
  }
}
