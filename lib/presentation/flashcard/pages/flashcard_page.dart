import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:baybai/presentation/flashcard/widgets/flashcard_controls.dart";
import "package:baybai/presentation/flashcard/widgets/flashcard_display.dart";
import "package:baybai/presentation/flashcard/widgets/flashcard_text.dart";
import "package:baybai/presentation/lessons/widgets/lesson_back_button.dart";

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final List<Map<String, String>> _flashcards = [
    {"character": "\u1700", "translation": "A"},
    {"character": "\u170A", "translation": "Ba"},
    {"character": "\u1703", "translation": "Ka"},
    {"character": "\u1707", "translation": "Da"},
    {"character": "\u1701", "translation": "E/I"},
    {"character": "\u1704", "translation": "Ga"},
    {"character": "\u1711", "translation": "Ha"},
    {"character": "\u170E", "translation": "La"},
    {"character": "\u170B", "translation": "Ma"},
    {"character": "\u1708", "translation": "Na"},
    {"character": "\u1705", "translation": "Nga"},
    {"character": "\u1702", "translation": "O/U"},
    {"character": "\u1709", "translation": "Pa"},
    {"character": "\u1710", "translation": "Sa"},
    {"character": "\u1706", "translation": "Ta"},
  ];

  int _currentIndex = 0;
  bool _isFlipped = false;

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Map<String, String> currentCard = _flashcards[_currentIndex];

    return Scaffold(
      appBar: _buildAppBar(context, isDarkMode),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              FlashcardProgress(
                currentIndex: _currentIndex,
                totalCards: _flashcards.length,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FlashcardDisplay(
                  character: currentCard["character"]!,
                  translation: currentCard["translation"]!,
                  isFlipped: _isFlipped,
                  onTap: _flipCard,
                ),
              ),
              const SizedBox(height: 64),
              FlashcardControls(
                onPrevious: _currentIndex > 0 ? _previousCard : null,
                onNext: _currentIndex < _flashcards.length - 1
                    ? _nextCard
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: Text(
        "Flashcards",
        style: AppTextStyles.bigbody.copyWith(
          color: isDarkMode ? AppColors.darkText : AppColors.text,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 72,
      leading: const Padding(
        padding: EdgeInsets.only(left: 24.0),
        child: Center(child: CustomBackButton()),
      ),
    );
  }
}
