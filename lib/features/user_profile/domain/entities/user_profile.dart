class UserProfile {
  final String name;
  final int currentLevel;
  final int completedLessons;
  final int dailyStreak;
  final int achievementsEarned;
  final List<Achievement> achievements;

  const UserProfile({
    required this.name,
    required this.currentLevel,
    required this.completedLessons,
    required this.dailyStreak,
    required this.achievementsEarned,
    required this.achievements,
  });
}

class Achievement {
  final String title;
  final String description;

  const Achievement({required this.title, required this.description});
}
