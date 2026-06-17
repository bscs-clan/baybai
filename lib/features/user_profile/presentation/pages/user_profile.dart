import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/user_profile/domain/entities/user_profile.dart";
import "package:baybai/shared/components/avatar/avatar.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;
import "package:solar_icons/solar_icons.dart";

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static const UserProfile _sampleProfile = UserProfile(
    name: "User Name",
    currentLevel: 1,
    completedLessons: 0,
    dailyStreak: 1,
    achievementsEarned: 0,
    achievements: [
      Achievement(title: "Beginner", description: "5 lessons"),
      Achievement(title: "Advanced", description: "10 lessons"),
      Achievement(title: "Master", description: "30 lessons"),
      Achievement(title: "Expert", description: "50 lessons"),
      Achievement(title: "Grind", description: "12 Streaks"),
      Achievement(title: "Quiz", description: "Passed Quiz 1"),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Center(
            child: CustomIconButton(
              icon: SolarIconsOutline.arrowLeft,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "User Profile",
          style: AppTextStyles.bigbody.copyWith(color: _textColor(isDarkMode)),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 20.0 : 24.0;
            final contentWidth = constraints.maxWidth > 720
                ? 680.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(
                        profile: _sampleProfile,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 24),
                      _StatsGrid(
                        profile: _sampleProfile,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 24),
                      _AchievementsSection(
                        achievements: _sampleProfile.achievements,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _textColor(bool isDarkMode) =>
      isDarkMode ? AppColors.darkWhite : AppColors.text;
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isDarkMode;

  const _ProfileHeader({required this.profile, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: ComponentShadow.primary,
          ),
          child: AppAvatar(
            name: profile.name,
            assetImage: "assets/images/img_profile.jpg",
            size: 104,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            badge: shadcn.AvatarBadge(color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading.copyWith(
            color: isDarkMode ? AppColors.darkWhite : AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        _buildTierBadge(profile.currentLevel, isDarkMode),
      ],
    );
  }

  Widget _buildTierBadge(int level, bool isDarkMode) {
    final tierInfo = _getTierInfo(level);
    final baseColor = tierInfo.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tierInfo.icon,
            size: 14,
            color: baseColor,
          ),
          const SizedBox(width: 6),
          Text(
            tierInfo.name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: baseColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserProfile profile;
  final bool isDarkMode;

  const _StatsGrid({required this.profile, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _ProfileStat(
        label: "Lessons",
        value: profile.completedLessons.toString(),
        icon: SolarIconsOutline.bookBookmark,
      ),
      _ProfileStat(
        label: "Achievements",
        value: profile.achievementsEarned.toString(),
        icon: SolarIconsOutline.cupStar,
      ),
    ];

    return Row(
      children: [
        Expanded(
          child: _StatCard(stat: stats[0], isDarkMode: isDarkMode),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(stat: stats[1], isDarkMode: isDarkMode),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final _ProfileStat stat;
  final bool isDarkMode;

  const _StatCard({required this.stat, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: ComponentColors.surface(context),
      borderRadius: BorderRadius.circular(ComponentRadius.lg),
      boxShadow: ComponentShadow.elevated(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppCard(
            width: 44,
            height: 44,
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ComponentRadius.sm),
            child: Center(
              child: Icon(stat.icon, size: 22, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bigbody.copyWith(
              color: isDarkMode ? AppColors.darkWhite : AppColors.text,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mbody.copyWith(
              color: isDarkMode ? AppColors.darkCompGrey : AppColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isDarkMode;

  const _AchievementsSection({
    required this.achievements,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Achievements",
                style: AppTextStyles.bigbody.copyWith(
                  color: isDarkMode ? AppColors.darkWhite : AppColors.text,
                ),
              ),
            ),
            Button(
              label: "View all",
              rightIcon: SolarIconsOutline.arrowRight,
              onTap: () => _showAchievementsGrid(context),
              type: ButtonType.ghost,
              size: ButtonSize.sm,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 560 ? 4 : 3;
            final aspectRatio = constraints.maxWidth >= 560 ? 1.05 : 0.72;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length > 6 ? 6 : achievements.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                return _AchievementGridCard(
                  achievement: achievements[index],
                  isDarkMode: isDarkMode,
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showAchievementsGrid(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _AchievementsGridScreen(achievements: achievements),
      ),
    );
  }
}

class _AchievementsGridScreen extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsGridScreen({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Center(
            child: CustomIconButton(
              icon: SolarIconsOutline.arrowLeft,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Achievements",
          style: AppTextStyles.bigbody.copyWith(
            color: isDarkMode ? AppColors.darkWhite : AppColors.text,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 720 ? 5 : (constraints.maxWidth >= 480 ? 4 : 3);
            final aspectRatio = constraints.maxWidth >= 560 ? 1.05 : 0.72;

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: achievements.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                return _AchievementGridCard(
                  achievement: achievements[index],
                  isDarkMode: isDarkMode,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AchievementGridCard extends StatelessWidget {
  final Achievement achievement;
  final bool isDarkMode;

  const _AchievementGridCard({
    required this.achievement,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final badgeInfo = _getAchievementBadgeInfo(achievement.title);
    final baseColor = badgeInfo.color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor.withValues(alpha: 0.12),
            border: Border.all(
              color: baseColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              badgeInfo.icon,
              color: baseColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          achievement.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title.copyWith(
            color: isDarkMode ? AppColors.darkWhite : AppColors.text,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          achievement.description,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mbody.copyWith(
            color: isDarkMode ? AppColors.darkCompGrey : AppColors.textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ProfileStat {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class TierInfo {
  final String name;
  final Color color;
  final IconData icon;

  const TierInfo({
    required this.name,
    required this.color,
    required this.icon,
  });
}

TierInfo _getTierInfo(int level) {
  final tierIndex = (level - 1) ~/ 3;
  final subLevel = 3 - ((level - 1) % 3);

  final bases = [
    _TierBase("Bronze", const Color(0xFFCD7F32), SolarIconsOutline.cupStar),
    _TierBase("Silver", const Color(0xFF78909C), SolarIconsOutline.medalStar),
    _TierBase("Gold", const Color(0xFFFFD700), SolarIconsOutline.cup),
    _TierBase("Platinum", const Color(0xFF06B6D4), SolarIconsOutline.stars),
    _TierBase("Diamond", const Color(0xFF3B82F6), SolarIconsOutline.bolt),
    _TierBase("Master", const Color(0xFFD946EF), SolarIconsOutline.fire),
  ];

  if (tierIndex >= bases.length) {
    return TierInfo(
      name: "Master",
      color: bases.last.color,
      icon: bases.last.icon,
    );
  }

  final base = bases[tierIndex];
  return TierInfo(
    name: "${base.name} $subLevel",
    color: base.color,
    icon: base.icon,
  );
}

class _TierBase {
  final String name;
  final Color color;
  final IconData icon;
  const _TierBase(this.name, this.color, this.icon);
}

class AchievementBadgeInfo {
  final IconData icon;
  final Color color;

  const AchievementBadgeInfo({required this.icon, required this.color});
}

AchievementBadgeInfo _getAchievementBadgeInfo(String title) {
  switch (title.toLowerCase()) {
    case "beginner":
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.book,
        color: Color(0xFF10B981),
      );
    case "advanced":
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.bookBookmark,
        color: Color(0xFF3B82F6),
      );
    case "master":
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.medalStar,
        color: Color(0xFFF59E0B),
      );
    case "expert":
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.cupStar,
        color: Color(0xFFEF4444),
      );
    case "grind":
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.fire,
        color: Color(0xFFF97316),
      );
    case "quiz":
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.stars,
        color: Color(0xFF8B5CF6),
      );
    default:
      return const AchievementBadgeInfo(
        icon: SolarIconsOutline.cup,
        color: Color(0xFF64748B),
      );
  }
}
