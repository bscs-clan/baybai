import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/flashcard/presentation/widgets/flashcard_options_bottom_sheet.dart";
import "package:baybai/features/home/presentation/widgets/explore_card.dart";
import "package:baybai/features/quiz/presentation/widgets/quiz_options_bottom_sheet.dart";

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildCard({
      required IconData icon,
      required String label,
      required String description,
      required String route,
      VoidCallback? onTap,
    }) {
      return Expanded(
        child: ExploreCard(
          icon: icon,
          label: label,
            description: description,
            onTap: onTap ?? () => Navigator.pushNamed(context, route),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore",
          style: AppTextStyles.bigbody.copyWith(
            color: AppColors.grey12,
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildCard(
                icon: Icons.school,
                label: "Lessons",
                description: "Learn Topics",
                route: "/lessons",
              ),
              const SizedBox(width: 8),
              buildCard(
                icon: Icons.quiz,
                label: "Quiz",
                description: "Test knowledge",
                route: "/quiz-setup",
                onTap: () => showQuizOptionsBottomSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildCard(
                icon: Icons.text_fields,
                label: "Characters",
                description: "Meet symbols",
                route: "/characters",
              ),
              const SizedBox(width: 8),
              buildCard(
                icon: Icons.edit,
                label: "Practice",
                description: "Write and test",
                route: "/practice",
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildCard(
                icon: Icons.library_books,
                label: "Flashcard",
                description: "Review vocab",
                route: "/flashcard",
                onTap: () => showFlashcardOptionsBottomSheet(context),
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }
}
