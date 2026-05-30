import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/quiz/presentation/pages/quiz_screen.dart";
import "package:baybai/features/quiz/presentation/widgets/difficulty_card.dart";
import "package:baybai/shared/components/buttons/button.dart";

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  QuizMode _selected = QuizMode.practice;

  @override
  void initState() {
    super.initState();
    _updateSettingsForMode(_selected);
  }

  void _updateSettingsForMode(QuizMode mode) {
    setState(() {
      _selected = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quiz ",
          style: AppTextStyles.bigbody.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Center(child: CustomBackButton()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode cards
            ...quizModes.map(
              (info) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ModeCard(
                  info: info,
                  isSelected: _selected == info.mode,
                  onTap: () => _updateSettingsForMode(info.mode),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.bottomRight,
              child: Button(
                label: "Start Quiz",
                onTap: () {
                  final modeInfo = quizModes.firstWhere(
                    (info) => info.mode == _selected,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(mode: modeInfo),
                    ),
                  );
                },
                type: ButtonType.primary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
