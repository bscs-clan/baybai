import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/explore_card.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget buildGameCard({
      required IconData icon,
      required String label,
      required String description,
      required String route,
    }) {
      return Expanded(
        child: ExploreCard(
          icon: icon,
          label: label,
          description: description,
          onTap: () => Navigator.pushNamed(context, route),
        ),
      );
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Game",
                style: AppTextStyles.bigbody.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildGameCard(
                      icon: AppSolarIcons.questionSquare,
                      label: "Quiz",
                      description: "Test knowledge",
                      route: "/quiz-setup",
                    ),
                    const SizedBox(width: 12),
                    buildGameCard(
                      icon: AppSolarIcons.flashcard,
                      label: "Flashcard",
                      description: "Review vocab",
                      route: "/flashcard",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
