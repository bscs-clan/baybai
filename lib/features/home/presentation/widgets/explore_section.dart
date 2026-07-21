import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/explore_card.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class ExploreSection extends StatelessWidget {
  final Map<int, bool> completedLessons;

  const ExploreSection({super.key, this.completedLessons = const {}});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget buildCard({
      required IconData icon,
      required String label,
      required String description,
      required String route,
      required bool isLocked,
    }) {
      return Expanded(
        child: ExploreCard(
          icon: icon,
          label: label,
          description: isLocked ? "Locked" : description,
          isLocked: isLocked,
          onTap: isLocked ? null : () => Navigator.pushNamed(context, route),
        ),
      );
    }

    final isGameLocked = !(completedLessons[1] ?? false);
    final isCharactersLocked = !(completedLessons[2] ?? false);
    final isPracticeLocked = !(completedLessons[3] ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore",
          style: AppTextStyles.bigbody.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildCard(
                icon: AppSolarIcons.lesson,
                label: "Lessons",
                description: "Learn Topics",
                route: "/lessons",
                isLocked: false,
              ),
              const SizedBox(width: 8),
              buildCard(
                icon: AppSolarIcons.game,
                label: "Games",
                description: "Play and learn",
                route: "/game",
                isLocked: isGameLocked,
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
                icon: AppSolarIcons.text,
                label: "Characters",
                description: "Meet symbols",
                route: "/characters",
                isLocked: isCharactersLocked,
              ),
              const SizedBox(width: 8),
              buildCard(
                icon: AppSolarIcons.pen,
                label: "Practice",
                description: "Write and test",
                route: "/practice",
                isLocked: isPracticeLocked,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
