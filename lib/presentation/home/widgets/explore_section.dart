import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/presentation/home/widgets/explore_card.dart";

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget buildCard({
      required String icon,
      required String label,
      required String route,
    }) {
      return Expanded(
        child: ExploreCard(
          icon: icon,
          label: label,
          onTap: () => Navigator.pushNamed(context, route),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore",
          style: AppTextStyles.bigbody.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          ),
        ),
        const SizedBox(height: 16),

        Column(
          children: [
            Row(
              children: [
                buildCard(
                  icon: "assets/icons/question-square.svg",
                  label: "Quiz",
                  route: "/quiz-setup",
                ),
                const SizedBox(width: 12),
                buildCard(
                  icon: "assets/icons/flashcard.svg",
                  label: "Flashcard",
                  route: "/flashcard",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                buildCard(
                  icon: "assets/icons/character.svg",
                  label: "Characters",
                  route: "/characters",
                ),
                const SizedBox(width: 12),
                buildCard(
                  icon: "assets/icons/practice.svg",
                  label: "Practice",
                  route: "/practice",
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 120),
      ],
    );
  }
}
