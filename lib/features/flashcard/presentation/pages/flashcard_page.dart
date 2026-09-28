import "dart:math" as math;
import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/flashcard/presentation/pages/flashcard_complete_page.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";

class FlashcardPage extends StatefulWidget {
  final String? cardCount;

  const FlashcardPage({super.key, this.cardCount});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  static const List<_Flashcard> _flashcards = [
    _Flashcard(front: "What sound does \u170A represent?", back: "ba"),
    _Flashcard(front: "What sound does \u1703 represent?", back: "ka"),
    _Flashcard(front: "What sound does \u170B represent?", back: "ma"),
    _Flashcard(front: "What sound does \u1710 represent?", back: "sa"),
    _Flashcard(front: "What sound does \u1700 represent?", back: "a"),
    _Flashcard(front: "What sound does \u1701 represent?", back: "i/e"),
    _Flashcard(front: "What sound does \u1702 represent?", back: "o/u"),
    _Flashcard(front: "What does \u170A\u1712 represent?", back: "bi/be"),
    _Flashcard(front: "What does \u170A\u1713 represent?", back: "bo/bu"),
    _Flashcard(front: "What does \u170A\u1714 represent?", back: "b"),
    _Flashcard(
      front: "What is the default vowel sound of a basic consonant?",
      back: "a",
    ),
    _Flashcard(
      front: "What does the top kudlit do?",
      back: "Changes the default \"a\" sound to i/e",
    ),
    _Flashcard(
      front: "What does the bottom kudlit do?",
      back: "Changes the default \"a\" sound to o/u",
    ),
    _Flashcard(
      front: "What does the virama do?",
      back: "Removes the default \"a\" sound",
    ),
    _Flashcard(
      front: "What type of writing system is Baybayin?",
      back: "An abugida",
    ),
    _Flashcard(
      front:
          "Does each Baybayin symbol represent a single letter or a syllable?",
      back: "A syllable",
    ),
    _Flashcard(
      front: "How should Baybayin words primarily be written?",
      back: "Based on pronunciation or sounds",
    ),
    _Flashcard(
      front: "How is \"BAHAY\" broken down using the syllabic approach?",
      back: "ba-ha-y",
    ),
    _Flashcard(front: "How is \"BATA\" broken down?", back: "ba-ta"),
    _Flashcard(front: "How is \"KAMUSTA\" broken down?", back: "ka-mus-ta"),
    _Flashcard(
      front: "How would \"CITY\" be adapted based on pronunciation?",
      back: "siti",
    ),
    _Flashcard(
      front: "How would \"PHOTO\" be adapted based on pronunciation?",
      back: "poto",
    ),
    _Flashcard(
      front: "How would \"KNIGHT\" be adapted based on pronunciation?",
      back: "nayt",
    ),
    _Flashcard(front: "How is the F sound commonly adapted?", back: "F -> P"),
    _Flashcard(front: "How is the V sound commonly adapted?", back: "V -> B"),
    _Flashcard(front: "How is the Z sound commonly adapted?", back: "Z -> S"),
    _Flashcard(
      front: "How is a hard C sound commonly adapted?",
      back: "C -> K",
    ),
    _Flashcard(
      front: "How is an English-style J sound commonly adapted?",
      back: "J -> DY",
    ),
    _Flashcard(front: "How is the PH sound commonly adapted?", back: "PH -> P"),
    _Flashcard(
      front:
          "What is the main principle of Baybayin emphasized in the lessons?",
      back: "Write what you hear based on pronunciation",
    ),
  ];

  int _currentIndex = 0;
  bool _isShowingBack = false;
  final Map<int, String> _cardStatuses = {};
  late final List<_Flashcard> _shuffledFlashcards;
  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _flipAnimation = CurvedAnimation(
    parent: _flipController,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _shuffledFlashcards = List<_Flashcard>.from(_flashcards)..shuffle();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  String? _getCardCountSelection(BuildContext context) {
    if (widget.cardCount != null) return widget.cardCount;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      return args["cardCount"] as String?;
    }
    return null;
  }

  int _getCardLimit(BuildContext context) {
    final selection = _getCardCountSelection(context);
    switch (selection) {
      case "Fewer":
        return 5;
      case "More":
        return 15;
      case "Standard":
      default:
        return 10;
    }
  }

  List<_Flashcard> _getActiveCards(BuildContext context) {
    final limit = _getCardLimit(context);
    return _shuffledFlashcards.take(limit).toList();
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _flipController.value = 0.0;
      setState(() {
        _currentIndex--;
        _isShowingBack = false;
      });
    }
  }

  void _toggleFlip() {
    if (_flipController.isAnimating) return;
    if (_isShowingBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isShowingBack = !_isShowingBack;
    });
  }

  void _markCorrect() {
    setState(() {
      if (_cardStatuses[_currentIndex] == 'Correct') {
        _cardStatuses.remove(_currentIndex);
      } else {
        _cardStatuses[_currentIndex] = 'Correct';
      }
    });
  }

  void _markWrong() {
    setState(() {
      if (_cardStatuses[_currentIndex] == 'Wrong') {
        _cardStatuses.remove(_currentIndex);
      } else {
        _cardStatuses[_currentIndex] = 'Wrong';
      }
    });
  }

  void _nextCard(List<_Flashcard> activeCards, String? cardCountSelection) {
    if (_currentIndex < activeCards.length - 1) {
      _flipController.value = 0.0;
      setState(() {
        _currentIndex++;
        _isShowingBack = false;
      });
    } else {
      final correctCount = activeCards
          .asMap()
          .entries
          .where((entry) => _cardStatuses[entry.key] == 'Correct')
          .length;
      final skippedCount = activeCards
          .asMap()
          .entries
          .where((entry) => !_cardStatuses.containsKey(entry.key))
          .length;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardCompletePage(
            correctAnswers: correctCount,
            totalQuestions: activeCards.length,
            skippedAnswers: skippedCount,
            cardCount: cardCountSelection,
            questionResults: activeCards
                .asMap()
                .entries
                .map(
                  (entry) => FlashcardQuestionResult(
                    questionNumber: entry.key + 1,
                    question: entry.value.front,
                    status: _cardStatuses[entry.key] ?? 'Skipped',
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
  }

  Widget _buildCardContainer({
    required int safeIndex,
    required int totalCards,
    required String? currentStatus,
    required String text,
    required TextStyle cardTextStyle,
    required bool isShowingBack,
  }) {
    return Container(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: currentStatus == 'Correct'
            ? const Color(0xFFDFF7E5)
            : currentStatus == 'Wrong'
            ? const Color(0xFFFDECEC)
            : (isShowingBack ? null : AppColors.grey5),
        borderRadius: BorderRadius.circular(24),
        border: isShowingBack
            ? (currentStatus == 'Correct'
                  ? Border.all(color: const Color(0xFF0B5F3C))
                  : currentStatus == 'Wrong'
                  ? Border.all(color: const Color(0xFFB42318))
                  : Border.all(color: AppColors.grey6))
            : null,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "${safeIndex + 1}/$totalCards",
              style: AppTextStyles.body.copyWith(color: AppColors.grey11),
            ),
          ),
          if (currentStatus == 'Correct')
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "Got It",
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF0B5F3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (currentStatus == 'Wrong')
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "Missed",
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFFB42318),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: _FlashcardText(
              text,
              textAlign: TextAlign.left,
              style: cardTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardCountSelection = _getCardCountSelection(context);
    final activeCards = _getActiveCards(context);
    final safeIndex = _currentIndex.clamp(0, activeCards.length - 1);
    final currentCard = activeCards[safeIndex];
    final currentStatus = _cardStatuses[safeIndex];
    final cardTextStyle = AppTextStyles.body.copyWith(
      color: _isShowingBack ? AppColors.grey12 : AppColors.grey12,
      fontSize: 24,
    );

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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  "Tap the Card to Flip",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.grey8),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _toggleFlip,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * math.pi;
                    final isShowingBackView = _flipAnimation.value >= 0.5;

                    final transform = Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateY(angle);

                    return Transform(
                      alignment: Alignment.center,
                      transform: transform,
                      child: isShowingBackView
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildCardContainer(
                                safeIndex: safeIndex,
                                totalCards: activeCards.length,
                                currentStatus: currentStatus,
                                text: currentCard.back,
                                cardTextStyle: cardTextStyle,
                                isShowingBack: true,
                              ),
                            )
                          : _buildCardContainer(
                              safeIndex: safeIndex,
                              totalCards: activeCards.length,
                              currentStatus: currentStatus,
                              text: currentCard.front,
                              cardTextStyle: cardTextStyle,
                              isShowingBack: false,
                            ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: Icons.arrow_back,
                    onTap: _currentIndex > 0 ? _previousCard : null,
                    size: 64,
                    color: Colors.transparent,
                    iconColor: _currentIndex > 0
                        ? AppColors.blue9
                        : AppColors.grey7,
                    borderColor: _currentIndex > 0
                        ? AppColors.blue9
                        : AppColors.grey3,
                  ),
                  CustomIconButton(
                    icon: Icons.check,
                    onTap: _markCorrect,
                    color: currentStatus == 'Correct'
                        ? const Color(0xFFDFF7E5)
                        : Colors.transparent,
                    iconColor: const Color(0xFF0B5F3C),
                    borderColor: currentStatus == 'Correct'
                        ? const Color(0xFF0B5F3C)
                        : AppColors.grey3,
                  ),
                  CustomIconButton(
                    icon: Icons.close,
                    onTap: _markWrong,
                    color: currentStatus == 'Wrong'
                        ? const Color(0xFFFDECEC)
                        : Colors.transparent,
                    iconColor: const Color(0xFFB42318),
                    borderColor: currentStatus == 'Wrong'
                        ? const Color(0xFFB42318)
                        : AppColors.grey3,
                  ),
                  CustomIconButton(
                    icon: Icons.arrow_forward,
                    onTap: () => _nextCard(activeCards, cardCountSelection),
                    size: 64,
                    color: Colors.transparent,
                    iconColor: AppColors.blue9,
                    borderColor: AppColors.blue9,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final TextStyle style;

  const _FlashcardText(
    this.text, {
    required this.textAlign,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final baybayinFontSize = (style.fontSize ?? 18) + 14;

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (final rune in text.runes)
            TextSpan(
              text: String.fromCharCode(rune),
              style: rune >= 0x1700 && rune <= 0x171F
                  ? TextStyle(fontSize: baybayinFontSize)
                  : null,
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

class _Flashcard {
  final String front;
  final String back;

  const _Flashcard({required this.front, required this.back});
}
