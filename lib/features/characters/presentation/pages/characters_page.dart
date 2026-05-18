import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/widgets/solar_icon.dart";

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  String selectedCategory = "All";
  final List<String> categories = [
    "All",
    "Vowels",
    "Consonants",
    "Kudlit Marks",
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> dummyCharacters = [
      {"symbol": "\u1700", "label": "A", "category": "Vowels"},
      {"symbol": "\u1701", "label": "E/I", "category": "Vowels"},
      {"symbol": "\u1702", "label": "O/U", "category": "Vowels"},
      {"symbol": "\u170A", "label": "Ba", "category": "Consonants"},
      {"symbol": "\u1703", "label": "Ka", "category": "Consonants"},
      {"symbol": "\u1707", "label": "Da/Ra", "category": "Consonants"},
      {"symbol": "\u1704", "label": "Ga", "category": "Consonants"},
      {"symbol": "\u1711", "label": "Ha", "category": "Consonants"},
      {"symbol": "\u170E", "label": "La", "category": "Consonants"},
      {"symbol": "\u170B", "label": "Ma", "category": "Consonants"},
      {"symbol": "\u1708", "label": "Na", "category": "Consonants"},
      {"symbol": "\u1705", "label": "Nga", "category": "Consonants"},
      {"symbol": "\u1709", "label": "Pa", "category": "Consonants"},
      {"symbol": "\u1710", "label": "Sa", "category": "Consonants"},
      {"symbol": "\u1706", "label": "Ta", "category": "Consonants"},
      {"symbol": "\u170F", "label": "Wa", "category": "Consonants"},
      {"symbol": "\u170C", "label": "Ya", "category": "Consonants"},
      {"symbol": "\u1714", "label": "Virama", "category": "Kudlit Marks"},
      {"symbol": "\u1712", "label": "Kudlit i/e", "category": "Kudlit Marks"},
      {"symbol": "\u1713", "label": "Kudlit u/o", "category": "Kudlit Marks"},
    ];

    final filteredCharacters = selectedCategory == "All"
        ? dummyCharacters
        : dummyCharacters
              .where((c) => c["category"] == selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Center(
            child: _buildHeaderButton(
              context,
              icon: AppSolarIcons.arrowLeft,
              onTap: () => Navigator.pop(context),
              isDarkMode: isDarkMode,
            ),
          ),
        ),
        title: Container(
          height: 48,
          decoration: ShapeDecoration(
            color: isDarkMode ? AppColors.darkBox : AppColors.compBg,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              SolarIcon(
                AppSolarIcons.magnifier,
                size: 20,
                color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: AppTextStyles.body.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search characters...",
                    hintStyle: AppTextStyles.body.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCategoryTabs(isDarkMode),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: filteredCharacters.length,
                itemBuilder: (context, index) {
                  final char = filteredCharacters[index];
                  return Container(
                    decoration: ShapeDecoration(
                      color: isDarkMode ? AppColors.darkBox : AppColors.box,
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          char["symbol"]!,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 38,
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.text,
                          ),
                        ),
                        Text(
                          char["label"]!,
                          style: AppTextStyles.mbody.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextGrey
                                : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkBox : AppColors.box,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SolarIcon(
            icon,
            size: 24,
            color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: categories.map((category) {
          bool isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: ShapeDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDarkMode ? AppColors.darkBox : AppColors.box),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? AppColors.darkText : AppColors.text),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
