import "dart:math" as math;
import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/flashcard/data/flashcard_bank.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_back_button.dart";
import "package:baybai/features/flashcard/presentation/pages/flashcard_complete_page.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";

class FlashcardPage extends StatefulWidget {
  final String? cardCount;
  final String difficulty;

  const FlashcardPage({super.key, this.cardCount, this.difficulty = "Easy"});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isShowingBack = false;
  final Map<int, String> _cardStatuses = {};
  late final List<FlashcardData> _shuffledFlashcards;
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
    _shuffledFlashcards =
        flashcardBank
            .where((card) => card.difficulty == widget.difficulty)
            .toList()
          ..shuffle();
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

  List<FlashcardData> _getActiveCards(BuildContext context) {
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

  void _nextCard(List<FlashcardData> activeCards, String? cardCountSelection) {
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
            difficulty: widget.difficulty,
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
            ? AppColors.bgSuccess
            : currentStatus == 'Wrong'
            ? AppColors.bgError
            : (isShowingBack ? null : AppColors.gray10),
        borderRadius: BorderRadius.circular(24),
        border: isShowingBack
            ? (currentStatus == 'Correct'
                  ? Border.all(color: AppColors.bgSuccessContrast)
                  : currentStatus == 'Wrong'
                  ? Border.all(color: AppColors.bgErrorContrast)
                  : Border.all(color: AppColors.gray20))
            : null,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "${safeIndex + 1}/$totalCards",
              style: AppTextStyles.body.copyWith(color: AppColors.gray90),
            ),
          ),
          if (currentStatus == 'Correct')
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "Got It",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.bgSuccessContrast,
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
                  color: AppColors.bgErrorContrast,
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
      color: _isShowingBack ? AppColors.gray100 : AppColors.gray100,
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
                  style: AppTextStyles.body.copyWith(color: AppColors.gray60),
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
                        ? AppColors.primary60
                        : AppColors.gray50,
                    borderColor: _currentIndex > 0
                        ? AppColors.primary60
                        : AppColors.gray20,
                  ),
                  CustomIconButton(
                    icon: Icons.check,
                    onTap: _markCorrect,
                    color: currentStatus == 'Correct'
                        ? AppColors.bgSuccess
                        : Colors.transparent,
                    borderColor: currentStatus == 'Correct'
                        ? AppColors.bgSuccessContrast
                        : AppColors.gray20,
                    iconColor: AppColors.bgSuccessContrast,
                  ),
                  CustomIconButton(
                    icon: Icons.close,
                    onTap: _markWrong,
                    color: currentStatus == 'Wrong'
                        ? AppColors.bgError
                        : Colors.transparent,
                    borderColor: currentStatus == 'Wrong'
                        ? AppColors.bgErrorContrast
                        : AppColors.gray20,
                    iconColor: AppColors.bgErrorContrast,
                  ),
                  CustomIconButton(
                    icon: Icons.arrow_forward,
                    onTap: () => _nextCard(activeCards, cardCountSelection),
                    size: 64,
                    color: Colors.transparent,
                    iconColor: AppColors.primary60,
                    borderColor: AppColors.primary60,
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
