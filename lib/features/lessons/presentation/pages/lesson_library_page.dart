import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/learn_card.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class LessonLibraryPage extends StatefulWidget {
  const LessonLibraryPage({super.key});

  @override
  State<LessonLibraryPage> createState() => _LessonLibraryPageState();
}

class _LessonLibraryPageState extends State<LessonLibraryPage> {
  int _unlockedLessons = 1;
  Map<int, bool> _completed = {};
  bool _isLoading = true;

  final List<_LessonGroup> _groups = [
    _LessonGroup(title: "Beginner", lessons: LessonData.lessonList),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

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

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = <int, bool>{};

    for (int i = 1; i <= LessonData.lessons.length; i++) {
      completed[i] = prefs.getBool("lesson_${i}_completed") ?? false;
    }
    final unlocked = _deriveUnlockedLessons(completed);
    await prefs.setInt("unlocked_lessons", unlocked);

    setState(() {
      _unlockedLessons = unlocked;
      _completed = completed;
      _isLoading = false;
    });
  }

  Future<void> _navigateToLesson(int lessonId) async {
    await Navigator.pushNamed(context, "/lesson", arguments: lessonId);
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lessons",
                style: AppTextStyles.bigbody.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 20),
              for (final group in _groups) ...[
                _LessonGroupSection(
                  group: group,
                  completed: _completed,
                  unlockedLessons: _unlockedLessons,
                  onLessonTap: _navigateToLesson,
                ),
                const SizedBox(height: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonGroupSection extends StatelessWidget {
  final _LessonGroup group;
  final int unlockedLessons;
  final Map<int, bool> completed;
  final Future<void> Function(int lessonId) onLessonTap;

  const _LessonGroupSection({
    required this.group,
    required this.unlockedLessons,
    required this.completed,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: AppTextStyles.bigbody.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          ),
        ),
        const SizedBox(height: 14),
        for (final lesson in group.lessons) ...[
          _LessonCardItem(
            lesson: lesson,
            unlockedLessons: unlockedLessons,
            completed: completed[lesson.id] ?? false,
            onLessonTap: onLessonTap,
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _LessonCardItem extends StatelessWidget {
  final LessonMetadata lesson;
  final int unlockedLessons;
  final bool completed;
  final Future<void> Function(int lessonId) onLessonTap;

  const _LessonCardItem({
    required this.lesson,
    required this.unlockedLessons,
    required this.completed,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = LessonData.lessons.containsKey(lesson.id);
    final isLocked = !hasContent || lesson.id > unlockedLessons;

    return LearnCard(
      lessonNumber: lesson.number,
      title: lesson.title,
      description: lesson.description,
      lessonId: lesson.id,
      isLocked: isLocked,
      isCompleted: completed,
      onTap: isLocked ? null : () => onLessonTap(lesson.id),
    );
  }
}

class _LessonGroup {
  final String title;
  final List<LessonMetadata> lessons;

  const _LessonGroup({required this.title, required this.lessons});
}
