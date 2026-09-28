import "package:flutter/material.dart";
import "package:baybai/features/home/presentation/widgets/explore_section.dart";
import "package:baybai/features/home/presentation/widgets/learn_card.dart";
import "package:baybai/features/home/presentation/widgets/learn_header.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";

class TabLearn extends StatelessWidget {
  const TabLearn({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLesson = LessonData.lessonList.firstWhere(
      (lesson) => LessonData.lessons.containsKey(lesson.id),
    orElse: () => LessonData.lessonList.first,
  );

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
              lessonId: currentLesson.id,
              onTap: () => Navigator.pushNamed(
                context,
                "/lesson",
                arguments: currentLesson.id,
              ),
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
