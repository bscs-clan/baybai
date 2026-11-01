import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";

Future<void> showFlashcardOptionsBottomSheet(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      var selectedDifficulty = "Easy";
      var selectedCardCount = "Standard";
      var selectedCardType = "Mixed";

      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              decoration: ShapeDecoration(
                color: isDarkMode ? AppColors.gray90 : AppColors.gray10,
                shape: const RoundedRectangleBorder(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.gray50 : AppColors.gray60,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Flashcards",
                    style: AppTextStyles.bigbody.copyWith(
                      color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Difficulty",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.gray10 : AppColors.gray90,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: "Easy",
                          label: Text("Easy"),
                        ),
                        ButtonSegment<String>(
                          value: "Medium",
                          label: Text("Medium"),
                        ),
                        ButtonSegment<String>(
                          value: "Hard",
                          label: Text("Hard"),
                        ),
                      ],
                      selected: {selectedDifficulty},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontWeight: FontWeight.normal),
                        ),
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.primary20
                                  : null,
                            ),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.gray100
                                  : null,
                            ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppColors.gray70, width: 1),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        setState(() {
                          selectedDifficulty = selection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Number of Cards",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.gray10 : AppColors.gray90,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: "Fewer",
                          label: Text("Fewer"),
                        ),
                        ButtonSegment<String>(
                          value: "Standard",
                          label: Text("Standard"),
                        ),
                        ButtonSegment<String>(
                          value: "More",
                          label: Text("More"),
                        ),
                      ],
                      selected: {selectedCardCount},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontWeight: FontWeight.normal),
                        ),
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.primary20
                                  : null,
                            ),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.gray100
                                  : null,
                            ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppColors.gray70, width: 1),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        setState(() {
                          selectedCardCount = selection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Card Type",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.gray10 : AppColors.gray90,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: "Characters",
                          label: Text("Characters"),
                        ),
                        ButtonSegment<String>(
                          value: "Questions",
                          label: Text("Questions"),
                        ),
                        ButtonSegment<String>(
                          value: "Mixed",
                          label: Text("Mixed"),
                        ),
                      ],
                      selected: {selectedCardType},
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontWeight: FontWeight.normal),
                        ),
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.primary20
                                  : null,
                            ),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.gray100
                                  : null,
                            ),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppColors.gray70, width: 1),
                        ),
                      ),
                      onSelectionChanged: (selection) {
                        setState(() {
                          selectedCardType = selection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                  Button(
                    label: "Start Flashcards",
                    width: double.infinity,
                    customBackgroundColor: AppColors.primary60,
                    onTap: () {
                      final navigator = Navigator.of(context);

                      Navigator.of(sheetContext).pop();
                      navigator.pushNamed(
                        "/flashcard",
                        arguments: {
                          "difficulty": selectedDifficulty,
                          "cardCount": selectedCardCount,
                          "cardType": selectedCardType,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
