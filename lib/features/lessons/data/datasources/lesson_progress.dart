import "package:shared_preferences/shared_preferences.dart";

class LessonProgress {
  static const _completedLessonsKey = "completed_lesson_ids";

  static Future<Set<int>> getCompletedLessonIds() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_completedLessonsKey) ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  static Future<void> markCompleted(int lessonId) async {
    final preferences = await SharedPreferences.getInstance();
    final completed = preferences.getStringList(_completedLessonsKey) ?? [];
    if (!completed.contains(lessonId.toString())) {
      completed.add(lessonId.toString());
      await preferences.setStringList(_completedLessonsKey, completed);
    }
  }
}
