import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
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

  int _deriveUnlockedLessons(Map<int, bool> completed) {
    var unlockedLessonId = 1;

    for (final lesson in LessonData.lessonList) {
      if (!LessonData.lessons.containsKey(lesson.id)) {
        continue;
      }

      if (lesson.id != unlockedLessonId) {
        break;
      }

      if (completed[lesson.id] ?? false) {
        unlockedLessonId = lesson.id + 1;
      } else {
        break;
      }
    }

    return unlockedLessonId;
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <int, bool>{};

    for (final lesson in LessonData.lessonList) {
      completed[lesson.id] =
          prefs.getBool('lesson_${lesson.id}_completed') ?? false;
    }
    final unlocked = _deriveUnlockedLessons(completed);
    await prefs.setInt('unlocked_lessons', unlocked);

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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentLesson = _currentLesson;
    final currentLessonId = currentLesson.id;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LearnHeader(),
            LearnCard(
              lessonNumber: currentLesson.number,
              title: currentLesson.title,
              description: currentLesson.description,
              lessonId: currentLessonId,
              isLocked: false,
              isCompleted: _completed[currentLessonId] ?? false,
              onTap: () => _navigateToLesson(currentLessonId),
            ),
            const SizedBox(height: 24),
            ExploreSection(completedLessons: _completed),
            const SizedBox(height: 124),
          ],
        ),
      ),
    );
  }
}
