import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/learn_card.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:flutter/material.dart";

class LessonLibraryPage extends StatelessWidget {
  const LessonLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: Text(
          "Lessons",
          style: AppTextStyles.bigbody.copyWith(color: AppColors.grey12),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final lesson in LessonData.lessonList) ...[
                _LessonCardItem(lesson: lesson),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCardItem extends StatelessWidget {
  final LessonMetadata lesson;

  const _LessonCardItem({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return LearnCard(
      lessonNumber: lesson.number,
      title: lesson.title,
      description: lesson.description,
      lessonId: lesson.id,
      isExpandable: true,
      onTap: () =>
          Navigator.pushNamed(context, "/lesson", arguments: lesson.id),
    );
  }
}
