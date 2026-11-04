import "package:flutter/material.dart";
import "package:baybai/features/home/presentation/widgets/explore_section.dart";
import "package:baybai/features/home/presentation/widgets/learn_card.dart";
import "package:baybai/features/home/presentation/widgets/learn_header.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/data/datasources/lesson_progress.dart";

class TabLearn extends StatefulWidget {
  const TabLearn({super.key});

  @override
  State<TabLearn> createState() => _TabLearnState();
}

class _TabLearnState extends State<TabLearn> {
  late final Future<Set<int>> _completedLessons =
      LessonProgress.getCompletedLessonIds();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LearnHeader(),
            FutureBuilder<Set<int>>(
              future: _completedLessons,
              builder: (context, snapshot) {
                final completed = snapshot.data ?? const <int>{};
                final availableLessons = LessonData.lessonList
                    .where(
                      (lesson) => LessonData.lessons.containsKey(lesson.id),
                    )
                    .toList(growable: false);
                final currentLesson = availableLessons.firstWhere(
                  (lesson) => !completed.contains(lesson.id),
                  orElse: () => availableLessons.last,
                );

                return LearnCard(
                  lessonNumber: currentLesson.number,
                  title: currentLesson.title,
                  description: currentLesson.description,
                  lessonId: currentLesson.id,
                  onTap: () => Navigator.pushNamed(
                    context,
                    "/lesson",
                    arguments: currentLesson.id,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const ExploreSection(),
            const SizedBox(height: 124),
          ],
        ),
      ),
    );
  }
}
