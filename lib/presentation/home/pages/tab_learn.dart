import "package:flutter/material.dart";
import "package:baybai/presentation/home/widgets/learn_card.dart";
import "package:baybai/presentation/home/widgets/learn_header.dart";
import "package:baybai/presentation/home/widgets/explore_section.dart";

class TabLearn extends StatelessWidget {
  const TabLearn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LearnHeader(userName: "Deobert"),
            SizedBox(height: 24),
            LearnCard(
              lessonNumber: "Lesson 1",
              title: "Baybayin Basics",
              lessonId: 1,
            ),
            SizedBox(height: 16),
            LearnCard(
              lessonNumber: "Lesson 2",
              title: "Understanding Sounds",
              lessonId: 2,
            ),
            SizedBox(height: 16),
            LearnCard(
              lessonNumber: "Lesson 3",
              title: "The Kudlit Mark",
              lessonId: 3,
            ),
            SizedBox(height: 32),
            ExploreSection(),
          ],
        ),
      ),
    );
  }
}
