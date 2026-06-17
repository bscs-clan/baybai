import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/widgets/explore_card.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class ExploreSection extends StatelessWidget {
  const ExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget buildCard({
      required IconData icon,
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
                  icon: AppSolarIcons.lesson,
                  label: "Lessons",
                  route: "/lessons",
                ),
                const SizedBox(width: 12),
                buildCard(
                  icon: AppSolarIcons.game,
                  label: "Games",
                  route: "/game",
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                buildCard(
                  icon: AppSolarIcons.character,
                  label: "Characters",
                  route: "/characters",
                ),
                const SizedBox(width: 12),
                buildCard(
                  icon: AppSolarIcons.practice,
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
