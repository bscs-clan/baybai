import "package:flutter/material.dart";
import "package:audioplayers/audioplayers.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/presentation/widgets/kudlit_practice_card.dart";
import "package:baybai/features/lessons/presentation/widgets/kudlit_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_card_items.dart";
import "package:baybai/features/lessons/presentation/widgets/character_sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/comparison_card.dart";
import "package:baybai/features/lessons/presentation/widgets/quiz_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/shared_kudlit_vowel_card.dart";
import "package:baybai/features/lessons/presentation/widgets/syllable_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/vowel_sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/word_sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/word_to_break_card.dart";
import "package:baybai/features/lessons/presentation/widgets/empty_slot.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LessonSlide extends StatefulWidget {
  final LessonContent lesson;
  final String? selectedOption;
  final bool hasChecked;
  final ValueChanged<String?>? onOptionSelected;

  const LessonSlide({
    super.key,
    required this.lesson,
    this.selectedOption,
    this.hasChecked = false,
    this.onOptionSelected,
  });

  @override
  State<LessonSlide> createState() => _LessonSlideState();
}

class _LessonSlideState extends State<LessonSlide> {
  late final List<String?> _droppedItems;

  @override
  void initState() {
    super.initState();
    final partsCount =
        widget.lesson.numSlots ??
        widget.lesson.matchCharacters?.length ??
        widget.lesson.correctOption?.split(',').length ??
        2;

    _droppedItems = List<String?>.filled(partsCount, null);
    _syncDroppedItems();
  }

  @override
  void didUpdateWidget(LessonSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOption != oldWidget.selectedOption) {
      _syncDroppedItems();
    }
  }

  void _syncDroppedItems() {
    if (widget.lesson.wordToBreak != null ||
        widget.lesson.matchCharacters != null) {
      if (widget.selectedOption != null) {
        final parts = widget.selectedOption!.split(',');
        for (int i = 0; i < _droppedItems.length; i++) {
          if (i < parts.length && parts[i] != 'null') {
            _droppedItems[i] = parts[i];
          } else {
            _droppedItems[i] = null;
          }
        }
      } else {
        if (!_droppedItems.contains(null)) {
          _droppedItems.fillRange(0, _droppedItems.length, null);
        }
      }
    }
  }

  IconData _mapLessonIcon(LessonIcon icon) {
    return switch (icon) {
      LessonIcon.confetti => AppSolarIcons.confetti,
    };
  }

  Widget _buildDescription(String text, bool isDarkMode) {
    final baseColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final baseStyle = AppTextStyles.body.copyWith(color: baseColor);

    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }

  List<String> _parseAnswerPieces(String? selectedOption) {
    if (selectedOption == null || selectedOption.trim().isEmpty) {
      return [];
    }

    return selectedOption
        .split(',')
        .map((piece) => piece.trim())
        .where((piece) => piece.isNotEmpty)
        .toList();
  }

  Widget _buildAnswerArea(bool isDarkMode) {
    final pieces = _parseAnswerPieces(widget.selectedOption);

    return Column(
      key: const ValueKey('answer-area'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.compGrey.withValues(alpha: 0.3),
            strokeWidth: 1.2,
            dashWidth: 6.0,
            gap: 4.0,
            borderRadius: 16.0,
          ),
          child: Container(
            width: double.infinity,
            height: 75,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: pieces.isEmpty
                ? const SizedBox.shrink()
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pieces
                        .map(
                          (piece) => GestureDetector(
                            key: ValueKey('answer-piece-$piece'),
                            onTap: () {
                              final existingPieces = _parseAnswerPieces(
                                widget.selectedOption,
                              );
                              final nextPieces = existingPieces
                                  .where(
                                    (existingPiece) => existingPiece != piece,
                                  )
                                  .toList();
                              final nextValue = nextPieces.isEmpty
                                  ? null
                                  : nextPieces.join(',');
                              widget.onOptionSelected?.call(nextValue);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(64),
                              ),
                              child: Text(
                                piece,
                                style: AppTextStyles.body.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.text,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (widget.lesson.icon != null) ...[
                      SolarIcon(
                        _mapLessonIcon(widget.lesson.icon!),
                        color: isDarkMode ? AppColors.darkText : AppColors.text,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        widget.lesson.title,
                        style: AppTextStyles.body.copyWith(
                          color: isDarkMode
                              ? AppColors.darkText
                              : AppColors.text,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (widget.lesson.showComparisonCard) const ComparisonCard(),
                if (widget.lesson.showSyllableTableCard)
                  const SyllableTableCard(),
                if (widget.lesson.showWordSoundTableCard)
                  const WordSoundTableCard(),
                if (widget.lesson.showCharacterSoundTableCard)
                  CharacterSoundTableCard(
                    examples: widget.lesson.characterSoundItems,
                  ),
                if (widget.lesson.showVowelSoundTableCard)
                  VowelSoundTableCard(examples: widget.lesson.vowelSoundItems),
                if (widget.lesson.showKudlitTableCard)
                  KudlitTableCard(examples: widget.lesson.kudlitTableItems),
                if (widget.lesson.showSharedKudlitVowelCard)
                  const SharedKudlitVowelCard(),
                if (widget.lesson.kudlitPracticeBaseSymbol != null) ...[
                  KudlitPracticeCard(
                    baseSymbol: widget.lesson.kudlitPracticeBaseSymbol!,
                    baseSound: widget.lesson.kudlitPracticeBaseSound ?? "",
                    targetSound: widget.lesson.kudlitPracticeTargetSound ?? "",
                    selectedOption: widget.selectedOption,
                  ),
                ],
                if (widget.lesson.showWordCard &&
                    widget.lesson.wordCardText != null) ...[
                  const SizedBox(height: 12),
                  _WordCard(word: widget.lesson.wordCardText!),
                ],
                if (widget.lesson.wordToBreak != null) ...[
                  WordToBreakCard(word: widget.lesson.wordToBreak!),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 24,
                    color:
                        (isDarkMode
                                ? AppColors.darkCompGrey
                                : AppColors.compGrey)
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _droppedItems.length; i++) ...[
                        _buildDragTarget(i),
                        if (i < _droppedItems.length - 1)
                          const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
                if (widget.lesson.matchCharacters != null) ...[
                  _buildCharacterMatchRows(isDarkMode),
                ],
                if (widget.lesson.showAnswerBox) ...[
                  const SizedBox(height: 12),
                  _buildAnswerArea(isDarkMode),
                ],
                if (widget.lesson.cardItems != null &&
                    widget.lesson.cardItems!.isNotEmpty)
                  LessonCardItems(
                    cardItems: widget.lesson.cardItems!,
                    isDarkMode: isDarkMode,
                  ),
                if (widget.lesson.description != null) ...[
                  const SizedBox(height: 24),
                  _buildDescription(widget.lesson.description!, isDarkMode),
                ],
                if (widget.lesson.showQuizTable &&
                    widget.lesson.baybayinText.isNotEmpty)
                  QuizTableCard(
                    symbol: widget.lesson.baybayinText,
                    selectedAnswer: widget.selectedOption,
                    hasChecked: widget.hasChecked,
                    correctOption: widget.lesson.correctOption,
                  )
                else if (widget.lesson.baybayinText.isNotEmpty &&
                    widget.lesson.options != null &&
                    widget.lesson.options!.isNotEmpty)
                  Center(
                    child: Text(
                      widget.lesson.baybayinText,
                      style: AppTextStyles.heading.copyWith(
                        fontFamily:
                            widget.lesson.baybayinFontFamily ?? 'Baybayin',
                        fontSize:
                            widget.lesson.baybayinFontSize ??
                            ((widget.lesson.baybayinFontFamily != null &&
                                    widget.lesson.baybayinFontFamily !=
                                        'Baybayin')
                                ? 64
                                : 96),
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.dark,
                        height: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.lesson.options != null &&
            widget.lesson.options!.isNotEmpty) ...[
          _buildOptionsBox(isDarkMode),
        ],
      ],
    );
  }

  Widget _buildOptionsBox(bool isDarkMode) {
    final isBreakMode = widget.lesson.wordToBreak != null;
    final isMatchMode = widget.lesson.matchCharacters != null;
    final isAnswerMode = widget.lesson.showAnswerBox;
    final isKudlitPractice = widget.lesson.kudlitPracticeBaseSymbol != null;
    final optionButtonHeight = widget.lesson.optionButtonHeight ?? 48;

    Widget grid = GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isKudlitPractice ? 1 : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        mainAxisExtent: optionButtonHeight,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(widget.lesson.options!.length, (index) {
        final option = widget.lesson.options![index];
        final isSelected = option == widget.selectedOption;
        final isCorrect = option == widget.lesson.correctOption;

        Color? customBg;
        Color? customFg;

        final isWrongSelected = widget.hasChecked && isSelected && !isCorrect;
        final isCorrectSelected = widget.hasChecked && isSelected && isCorrect;

        if (isSelected && !widget.hasChecked) {
          customBg = AppColors.compBg;
          customFg = AppColors.dark;
        } else if (isCorrectSelected) {
          customBg = AppColors.primary.withValues(alpha: .5);
          customFg = AppColors.dark;
        } else if (isWrongSelected) {
          customBg = AppColors.dark.withValues(alpha: .5);
          customFg = AppColors.dark;
        }

        if (isAnswerMode) {
          final existingPieces = _parseAnswerPieces(widget.selectedOption);
          final isAlreadySelected = existingPieces.contains(option);

          if (isAlreadySelected) {
            customBg = AppColors.compBg;
            customFg = AppColors.dark;
          }

          return Button(
            label: option,
            size: ButtonSize.md,
            type: ButtonType.secondary,
            height: optionButtonHeight,
            iconSize: 24.0,
            textStyle: AppTextStyles.body.copyWith(
              fontFamily: widget.lesson.optionFontFamily,
              fontSize: widget.lesson.optionFontSize,
            ),
            customBackgroundColor: customBg,
            customForegroundColor: customFg,
            onTap: widget.hasChecked
                ? null
                : () {
                    final nextPieces = isAlreadySelected
                        ? existingPieces
                              .where((piece) => piece != option)
                              .toList()
                        : [...existingPieces, option];
                    final nextValue = nextPieces.isEmpty
                        ? null
                        : nextPieces.join(',');
                    widget.onOptionSelected?.call(nextValue);
                  },
          );
        }

        if (isMatchMode) {
          final isDropped = _droppedItems.contains(option);
          final optionButton = AbsorbPointer(
            child: Button(
              label: option,
              size: ButtonSize.md,
              type: ButtonType.secondary,
              height: optionButtonHeight,
              iconSize: 24.0,
              borderRadius: BorderRadius.circular(64),
              textStyle: AppTextStyles.body.copyWith(
                fontFamily: widget.lesson.optionFontFamily,
                fontSize: widget.lesson.optionFontSize,
              ),
              customBackgroundColor: AppColors.white,
              customForegroundColor: AppColors.text,
              onTap: () {},
            ),
          );

          if (isDropped || widget.hasChecked) {
            return Opacity(opacity: 0.3, child: optionButton);
          }

          return Draggable<String>(
            data: option,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(width: 150, child: optionButton),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: optionButton),
            child: optionButton,
          );
        }

        final buttonWidget = Button(
          label: option,
          size: ButtonSize.md,
          type: ButtonType.secondary,
          height: optionButtonHeight,
          iconSize: 24.0,
          textStyle: AppTextStyles.body.copyWith(
            fontFamily: widget.lesson.optionFontFamily,
            fontSize: widget.lesson.optionFontSize,
          ),
          customBackgroundColor: customBg,
          customForegroundColor: customFg,
          onTap: (widget.hasChecked && !isSelected)
              ? null
              : () {
                  widget.onOptionSelected?.call(option);
                },
        );

        if (isBreakMode) {
          final isDropped = _droppedItems.contains(option);
          final breakButton = DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Button(
              label: option,
              size: ButtonSize.md,
              type: ButtonType.secondary,
              height: optionButtonHeight,
              iconSize: 24.0,
              borderRadius: BorderRadius.circular(64),
              textStyle: AppTextStyles.body.copyWith(
                fontFamily: widget.lesson.optionFontFamily,
                fontSize: widget.lesson.optionFontSize,
              ),
              customBackgroundColor: AppColors.white,
              customForegroundColor: AppColors.text,
              onTap: isDropped || widget.hasChecked
                  ? null
                  : () {
                      final emptyIndex = _droppedItems.indexOf(null);
                      if (emptyIndex != -1) {
                        setState(() {
                          _droppedItems[emptyIndex] = option;
                        });
                        if (!_droppedItems.contains(null)) {
                          widget.onOptionSelected?.call(
                            _droppedItems.join(','),
                          );
                        }
                      }
                    },
            ),
          );

          if (isDropped) {
            return Opacity(opacity: 0.3, child: breakButton);
          }
          return breakButton;
        }

        return buttonWidget;
      }),
    );

    final optionsContent = Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.compGrey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, isBreakMode ? 2 : 16),
      child: grid,
    );

    if (!isAnswerMode) {
      return optionsContent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [optionsContent],
    );
  }

  Widget _buildCharacterMatchRows(bool isDarkMode) {
    final characters = widget.lesson.matchCharacters!;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Column(
      children: List.generate(characters.length, (index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == characters.length - 1 ? 0 : 12,
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Text(
                  characters[index],
                  style: AppTextStyles.heading.copyWith(
                    fontFamily: "Baybayin",
                    fontSize: 34,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: textColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              Expanded(child: _buildDragTarget(index, expand: false)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDragTarget(int index, {bool expand = true}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final optionButtonHeight = widget.lesson.optionButtonHeight ?? 48;
    final dragTarget = DragTarget<String>(
      onAcceptWithDetails: (details) {
        if (widget.hasChecked) return;
        setState(() {
          _droppedItems[index] = details.data;
        });
        if (!_droppedItems.contains(null)) {
          widget.onOptionSelected?.call(_droppedItems.join(','));
        }
      },
      builder: (context, candidateData, rejectedData) {
        if (_droppedItems[index] != null) {
          Color? customBg;
          Color? customFg;

          if (widget.hasChecked) {
            final correctParts = widget.lesson.correctOption?.split(',');
            final isCorrect =
                correctParts != null &&
                index < correctParts.length &&
                _droppedItems[index] == correctParts[index];

            if (isCorrect) {
              customBg = AppColors.primary.withValues(alpha: .5);
              customFg = AppColors.dark;
            } else {
              customBg = AppColors.dark.withValues(alpha: .5);
              customFg = AppColors.dark;
            }
          } else {
            customBg = isDarkMode ? AppColors.darkCompLight : AppColors.white;
          }

          return SizedBox(
            height: optionButtonHeight,
            child: Button(
              label: _droppedItems[index]!,
              size: ButtonSize.md,
              type: ButtonType.secondary,
              height: optionButtonHeight,
              textStyle: AppTextStyles.body.copyWith(
                fontFamily: widget.lesson.optionFontFamily,
                fontSize: widget.lesson.optionFontSize,
              ),
              customBackgroundColor: customBg,
              customForegroundColor: customFg,
              onTap: widget.hasChecked
                  ? null
                  : () {
                      setState(() {
                        _droppedItems[index] = null;
                      });
                      widget.onOptionSelected?.call(null);
                    },
            ),
          );
        }
        return const EmptySlot();
      },
    );

    if (!expand) {
      return dragTarget;
    }

    return Expanded(child: dragTarget);
  }
}

class _WordCard extends StatefulWidget {
  final String word;
  const _WordCard({required this.word});

  @override
  State<_WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<_WordCard> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      // Plays a standard audio asset like f_bata.mp3 or corresponding audio if named after the word
      await _audioPlayer.play(AssetSource("audio/f_bata.mp3"));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode
        ? AppColors.darkListSeparator
        : AppColors.listSeparator;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.word,
              style: AppTextStyles.heading.copyWith(
                color: textColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _playSound,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? AppColors.primary
                      : (isDarkMode ? AppColors.primary : AppColors.cardBlue),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SolarIcon(
                    AppSolarIcons.volume,
                    size: 24,
                    color: isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
