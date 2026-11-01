import "dart:math";

import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/presentation/widgets/kudlit_practice_card.dart";
import "package:baybai/features/lessons/presentation/widgets/kudlit_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/virama_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_card_items.dart";
import "package:baybai/features/lessons/presentation/widgets/character_sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/character_match_card.dart";
import "package:baybai/features/lessons/presentation/widgets/final_consonant_card.dart";
import "package:baybai/features/lessons/presentation/widgets/sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/comparison_card.dart";
import "package:baybai/features/lessons/presentation/widgets/quiz_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/shared_kudlit_vowel_card.dart";
import "package:baybai/features/lessons/presentation/widgets/syllable_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/vowel_sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/vowel_stroke_demo_card.dart";
import "package:baybai/features/lessons/presentation/widgets/word_sound_table_card.dart";
import "package:baybai/features/lessons/presentation/widgets/word_card.dart";
import "package:baybai/features/lessons/presentation/widgets/word_to_break_card.dart";
import "package:baybai/features/lessons/presentation/widgets/empty_slot.dart";
import "package:baybai/features/lessons/presentation/widgets/break_word_drag_slot.dart";
import "package:baybai/features/lessons/presentation/widgets/lesson_text_answer_input.dart";
import "package:baybai/shared/components/buttons/button.dart";

class LessonSlide extends StatefulWidget {
  final LessonContent lesson;
  final int? lessonId;
  final String? selectedOption;
  final bool hasChecked;
  final ValueChanged<String?>? onOptionSelected;

  const LessonSlide({
    super.key,
    required this.lesson,
    this.lessonId,
    this.selectedOption,
    this.hasChecked = false,
    this.onOptionSelected,
  });

  @override
  State<LessonSlide> createState() => _LessonSlideState();
}

class _LessonSlideState extends State<LessonSlide> {
  late final List<String?> _droppedItems;
  late final List<String> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    _shuffledOptions = List<String>.of(widget.lesson.options ?? const [])
      ..shuffle(Random());
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

  List<List<dynamic>> _mapLessonIcon(LessonIcon icon) {
    return switch (icon) {
      LessonIcon.confetti => HugeIcons.strokeRoundedParty,
    };
  }

  Widget _buildTextWithBoldMarkers(String text, bool isDarkMode) {
    final baseColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final baseStyle = AppTextStyles.regularSm.copyWith(color: baseColor);

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
          style: AppTextStyles.boldSm.copyWith(color: baseColor),
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
    final optionButtonHeight = widget.lesson.optionButtonHeight ?? 48;

    return Column(
      key: const ValueKey('answer-area'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.gray20,
            strokeWidth: 1.2,
            dashWidth: 6.0,
            gap: 4.0,
            borderRadius: 16.0,
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: optionButtonHeight + 28),
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
                          (piece) => IntrinsicWidth(
                            child: Button(
                              key: ValueKey('answer-piece-$piece'),
                              label: piece,
                              size: ButtonSize.sm,
                              type: ButtonType.secondary,
                              height: optionButtonHeight,
                              borderRadius: BorderRadius.circular(16),
                              customBackgroundColor: AppColors.primary20,
                              customForegroundColor: AppColors.primary100,
                              textStyle: AppTextStyles.boldSm.copyWith(
                                fontFamily: widget.lesson.optionFontFamily,
                                fontSize: widget.lesson.optionFontSize,
                              ),
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
    final lessonTitle = widget.lesson.title;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (lessonTitle != null && lessonTitle.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (widget.lesson.icon != null) ...[
                          HugeIcon(
                            icon: _mapLessonIcon(widget.lesson.icon!),
                            color: isDarkMode
                                ? AppColors.gray10
                                : AppColors.gray100,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: _buildTextWithBoldMarkers(
                            lessonTitle,
                            isDarkMode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.lesson.showComparisonCard)
                    ComparisonCard(
                      audioAsset: widget.lessonId == 1
                          ? "audio/ba.mp3"
                          : "audio/f_bata.mp3",
                    ),
                  if (widget.lesson.showSyllableTableCard)
                    const SyllableTableCard(),
                  if (widget.lesson.showWordSoundTableCard)
                    WordSoundTableCard(
                      examples:
                          widget.lesson.wordSoundTableItems ??
                          const [
                            WordSoundTableItem(word: "City", sound: "Siti"),
                            WordSoundTableItem(word: "Knight", sound: "Nayt"),
                            WordSoundTableItem(word: "Photo", sound: "Poto"),
                            WordSoundTableItem(word: "School", sound: "Skul"),
                            WordSoundTableItem(word: "Cake", sound: "Keyk"),
                          ],
                      leftTitle:
                          widget.lesson.wordSoundTableFirstColumnTitle ??
                          "Words",
                      rightTitle:
                          widget.lesson.wordSoundTableSecondColumnTitle ??
                          "Sounds Like",
                      soundHorizontalMargin:
                          widget.lesson.wordSoundTableFirstColumnTitle ==
                                  "Words with V" &&
                              widget.lesson.wordSoundTableSecondColumnTitle ==
                                  "Adapted Form"
                          ? 4
                          : 16,
                      boldFP:
                          widget.lesson.wordSoundTableFirstColumnTitle ==
                              "Words with F" &&
                          widget.lesson.wordSoundTableSecondColumnTitle ==
                              "Changes to P",
                      boldCharacters:
                          widget.lesson.wordSoundTableFirstColumnTitle ==
                                  "Words with V" &&
                              widget.lesson.wordSoundTableSecondColumnTitle ==
                                  "Adapted Form"
                          ? const {"V", "B"}
                          : widget.lesson.wordSoundTableFirstColumnTitle ==
                                    "Words with Z" &&
                                widget.lesson.wordSoundTableSecondColumnTitle ==
                                    "Adapted Form"
                          ? const {"Z", "S"}
                          : const {},
                    ),
                  if (widget.lesson.showCharacterSoundTableCard)
                    CharacterSoundTableCard(
                      examples: widget.lesson.characterSoundItems,
                    ),
                  if (widget.lesson.showSoundTableCard)
                    SoundTableCard(
                      title: widget.lesson.soundTableTitle,
                      mappings: widget.lesson.soundTableMappings ?? const [],
                      examples: widget.lesson.soundTableExamples ?? const [],
                      playMappings:
                          !widget.lesson.soundTableExamplesOnlyAudio &&
                          (widget.lesson.playSoundTableMappings ||
                              (widget.lessonId != null &&
                                  widget.lessonId! >= 7 &&
                                  widget.lessonId! <= 12)),
                      playExamples: widget.lesson.playSoundTableExamples,
                      boldFP: widget.lesson.boldSoundTableFP,
                      boldVBExamples: widget.lesson.boldSoundTableVBExamples,
                      boldMappings: widget.lesson.boldSoundTableMappings,
                      boldMappingPrefixLength:
                          widget.lesson.boldSoundTableMappingPrefixLength,
                      boldMappingSoundPrefixLength:
                          widget.lesson.boldSoundTableMappingSoundPrefixLength,
                      boldExampleMappings:
                          widget.lesson.boldSoundTableExampleMappings,
                      boldXKSExamples: widget.lesson.boldSoundTableXKSExamples,
                      boldNYExamples: widget.lesson.boldSoundTableNYExamples,
                      boldAudioP: widget.lesson.boldSoundTableAudioP,
                    ),
                  if (widget.lesson.showFinalConsonantCard)
                    const FinalConsonantCard(),
                  if (widget.lesson.showVowelSoundTableCard)
                    VowelSoundTableCard(
                      examples: widget.lesson.vowelSoundItems,
                    ),
                  if (widget.lesson.showKudlitTableCard)
                    KudlitTableCard(examples: widget.lesson.kudlitTableItems),
                  if (widget.lesson.showViramaTableCard)
                    ViramaTableCard(
                      showQuestionMark: widget.lesson.showViramaQuestionMark,
                      playAudio: widget.lesson.playViramaAudio,
                      baseSymbol: widget.lesson.viramaBaseSymbol ?? "\u170A",
                      baseSound: widget.lesson.viramaBaseSound ?? "Ba",
                    ),
                  if (widget.lesson.showSharedKudlitVowelCard)
                    const SharedKudlitVowelCard(),
                  if (widget.lesson.showStrokeDemoCard &&
                      widget.lesson.strokeDemoItems != null &&
                      widget.lesson.strokeDemoItems!.isNotEmpty)
                    VowelStrokeDemoCard(items: widget.lesson.strokeDemoItems!),
                  if (widget.lesson.kudlitPracticeBaseSymbol != null) ...[
                    KudlitPracticeCard(
                      baseSymbol: widget.lesson.kudlitPracticeBaseSymbol!,
                      baseSound: widget.lesson.kudlitPracticeBaseSound ?? "",
                      targetSound:
                          widget.lesson.kudlitPracticeTargetSound ?? "",
                      selectedOption: widget.selectedOption,
                    ),
                  ],
                  if (widget.lesson.showWordCard &&
                      widget.lesson.wordCardText != null) ...[
                    const SizedBox(height: 12),
                    WordCard(
                      word: widget.lesson.wordCardText!,
                      audioAsset:
                          widget.lesson.audioAsset ?? "audio/f_bata.mp3",
                      showAudioButton: widget.lesson.showWordCardAudio,
                    ),
                  ],
                  if (widget.lesson.wordToBreak != null) ...[
                    WordToBreakCard(word: widget.lesson.wordToBreak!),
                    if (!widget.lesson.showAnswerBox) ...[
                      const SizedBox(height: 42),
                      Text(
                        "Drag here",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regularXs.copyWith(
                          color: AppColors.gray50,
                        ),
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
                  ],
                  if (widget.lesson.matchCharacters != null) ...[
                    CharacterMatchCard(
                      characters: widget.lesson.matchCharacters!,
                      isDarkMode: isDarkMode,
                      answerSlots: List.generate(
                        widget.lesson.matchCharacters!.length,
                        (index) => _buildDragTarget(index, expand: false),
                      ),
                    ),
                  ],
                  if (widget.lesson.showAnswerBox) ...[
                    const SizedBox(height: 12),
                    _buildAnswerArea(isDarkMode),
                  ],
                  if (widget.lesson.cardItems != null &&
                      widget.lesson.cardItems!.isNotEmpty)
                    LessonCardItems(cardItems: widget.lesson.cardItems!),
                  if (widget.lesson.description != null) ...[
                    const SizedBox(height: 24),
                    _buildTextWithBoldMarkers(
                      widget.lesson.description!,
                      isDarkMode,
                    ),
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
                        style: AppTextStyles.boldXl.copyWith(
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
                          color: isDarkMode ? AppColors.bg : AppColors.gray100,
                          height: 1.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.lesson.showTextInput) ...[
          _buildTextAnswerInput(),
        ] else if (widget.lesson.options != null &&
            widget.lesson.options!.isNotEmpty) ...[
          _buildOptionsBox(isDarkMode),
        ],
      ],
    );
  }

  Widget _buildTextAnswerInput() {
    return LessonTextAnswerInput(
      answer: widget.selectedOption,
      enabled: !widget.hasChecked,
      onChanged: widget.onOptionSelected,
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
        crossAxisCount: isKudlitPractice || _shuffledOptions.length == 3
            ? 1
            : 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        mainAxisExtent: optionButtonHeight,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(_shuffledOptions.length, (index) {
        final option = _shuffledOptions[index];
        final isSelected = option == widget.selectedOption;
        final isCorrect = option == widget.lesson.correctOption;

        Color? customBg;
        Color? customFg;

        final isWrongSelected = widget.hasChecked && isSelected && !isCorrect;
        final isCorrectSelected = widget.hasChecked && isSelected && isCorrect;

        if (isSelected && !widget.hasChecked) {
          customBg = AppColors.gray20;
          customFg = AppColors.gray100;
        } else if (isCorrectSelected) {
          customBg = AppColors.primary60.withValues(alpha: .5);
          customFg = AppColors.gray100;
        } else if (isWrongSelected) {
          customBg = AppColors.gray100.withValues(alpha: .5);
          customFg = AppColors.gray100;
        }

        if (isAnswerMode) {
          final existingPieces = _parseAnswerPieces(widget.selectedOption);
          final isAlreadySelected = existingPieces.contains(option);

          if (isAlreadySelected) {
            return const SizedBox.expand();
          }

          return Button(
            label: option,
            size: ButtonSize.md,
            type: ButtonType.secondary,
            height: optionButtonHeight,
            iconSize: 24.0,
            borderRadius: BorderRadius.circular(16),
            textStyle: AppTextStyles.boldSm.copyWith(
              fontFamily: widget.lesson.optionFontFamily,
              fontSize: widget.lesson.optionFontSize,
            ),
            customBackgroundColor: AppColors.primary20,
            customForegroundColor: AppColors.primary100,
            onTap: widget.hasChecked
                ? null
                : () {
                    final nextPieces = [...existingPieces, option];
                    final nextValue = nextPieces.isEmpty
                        ? null
                        : nextPieces.join(',');
                    widget.onOptionSelected?.call(nextValue);
                  },
          );
        }

        if (isMatchMode) {
          final isDropped = _droppedItems.contains(option);
          final optionButton = DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AbsorbPointer(
                  child: Button(
                    label: option,
                    size: ButtonSize.sm,
                    type: ButtonType.secondary,
                    height: optionButtonHeight,
                    iconSize: 24.0,
                    borderRadius: BorderRadius.circular(16),
                    customBackgroundColor: isDarkMode
                        ? AppColors.gray90
                        : AppColors.primary20,
                    textStyle: AppTextStyles.boldSm.copyWith(
                      fontFamily: widget.lesson.optionFontFamily,
                      fontSize: widget.lesson.optionFontSize,
                    ),
                    customForegroundColor: AppColors.primary100,
                    onTap: () {},
                  ),
                ),
                Positioned(
                  left: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 12,
                      height: optionButtonHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary30,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (row) => Padding(
                              padding: EdgeInsets.only(
                                bottom: row == 4 ? 0 : 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildGripDot(),
                                  const SizedBox(width: 3),
                                  _buildGripDot(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

        final isWordCardOption = widget.lesson.showWordCard;
        final isBaybayinWordQuiz =
            isWordCardOption && widget.lesson.optionFontFamily == "Baybayin";
        final isLessonOneSoundQuiz = const {
          "CAKE",
          "PHOTO",
          "COFFEE",
        }.contains(widget.lesson.wordCardText?.toUpperCase());
        final isLessonFiveSoundQuiz = const {
          "F",
          "FAMILY",
          "FORK",
        }.contains(widget.lesson.wordCardText?.toUpperCase());
        final isLessonsSixToTwelve =
            widget.lessonId != null &&
            widget.lessonId! >= 6 &&
            widget.lessonId! <= 12;
        final isBaybayinPromptSoundQuiz =
            isWordCardOption &&
            (widget.lesson.wordCardText?.runes.any(
                  (rune) => rune >= 0x1700 && rune <= 0x171f,
                ) ??
                false) &&
            !isBaybayinWordQuiz;
        final isQuizTableOption = widget.lesson.showQuizTable;
        final isViramaQuiz = widget.lesson.showViramaQuestionMark;
        final isLessonThreeBaybayinQuiz =
            isWordCardOption &&
            widget.lesson.optionFontFamily == "Baybayin" &&
            const {
              "BE",
              "KO",
            }.contains(widget.lesson.wordCardText?.toUpperCase());
        final useSoundQuizStyle =
            isLessonOneSoundQuiz ||
            isLessonFiveSoundQuiz ||
            isLessonsSixToTwelve ||
            isBaybayinPromptSoundQuiz ||
            isQuizTableOption ||
            isKudlitPractice ||
            isLessonThreeBaybayinQuiz ||
            isBaybayinWordQuiz ||
            isViramaQuiz;
        final isWordCardSelected = isWordCardOption && isSelected;
        final useRoundedOptionStyle =
            isWordCardOption ||
            isLessonsSixToTwelve ||
            isQuizTableOption ||
            isKudlitPractice ||
            isViramaQuiz;
        final buttonWidget = Button(
          label: option,
          size: isLessonThreeBaybayinQuiz || isBaybayinWordQuiz
              ? ButtonSize.sm
              : ButtonSize.md,
          type: useSoundQuizStyle || isWordCardSelected
              ? ButtonType.secondary
              : isWordCardOption
              ? ButtonType.outline
              : ButtonType.secondary,
          height: optionButtonHeight,
          iconSize: 24.0,
          borderRadius: useRoundedOptionStyle
              ? BorderRadius.circular(16)
              : null,
          customBorderColor: useRoundedOptionStyle ? AppColors.gray20 : null,
          textStyle:
              (useSoundQuizStyle
                      ? AppTextStyles.boldSm
                      : AppTextStyles.regularSm)
                  .copyWith(
                    fontFamily: widget.lesson.optionFontFamily,
                    fontSize: widget.lesson.optionFontSize,
                    height: widget.lesson.optionFontFamily == "Baybayin"
                        ? 1.3
                        : null,
                  ),
          customBackgroundColor: isBaybayinWordQuiz
              ? (isSelected ? AppColors.primary20 : AppColors.gray10)
              : useSoundQuizStyle
              ? (isSelected ? AppColors.primary20 : AppColors.gray10)
              : isWordCardSelected
              ? AppColors.gray20
              : isWordCardOption
              ? (customBg ?? Colors.transparent)
              : customBg,
          customForegroundColor: isBaybayinWordQuiz
              ? (isSelected ? AppColors.primary100 : AppColors.gray100)
              : useSoundQuizStyle
              ? (isSelected ? AppColors.primary100 : AppColors.gray100)
              : isWordCardOption
              ? (customFg ?? AppColors.gray100)
              : customFg,
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AbsorbPointer(
                  child: Button(
                    label: option,
                    size: ButtonSize.sm,
                    type: ButtonType.secondary,
                    height: optionButtonHeight,
                    iconSize: 24.0,
                    borderRadius: BorderRadius.circular(16),
                    customBackgroundColor: isDarkMode
                        ? AppColors.gray90
                        : AppColors.primary20,
                    textStyle: AppTextStyles.boldSm.copyWith(
                      fontFamily: widget.lesson.optionFontFamily,
                      fontSize: widget.lesson.optionFontSize,
                    ),
                    customForegroundColor: AppColors.primary100,
                    onTap: () {},
                  ),
                ),
                Positioned(
                  left: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 12,
                      height: optionButtonHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary30,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (row) => Padding(
                              padding: EdgeInsets.only(
                                bottom: row == 4 ? 0 : 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildGripDot(),
                                  const SizedBox(width: 3),
                                  _buildGripDot(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isDropped || widget.hasChecked) {
            return Opacity(opacity: 0, child: breakButton);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return Draggable<String>(
                data: option,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: breakButton,
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0, child: breakButton),
                child: breakButton,
              );
            },
          );
        }

        return buttonWidget;
      }),
    );

    final optionsContent = Container(
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

  Widget _buildGripDot() => Container(
    width: 2.5,
    height: 2.5,
    decoration: const BoxDecoration(
      color: AppColors.primary50,
      shape: BoxShape.circle,
    ),
  );

  Widget _buildDragTarget(int index, {bool expand = true}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final optionButtonHeight = widget.lesson.optionButtonHeight ?? 48;
    final isBreakMode = widget.lesson.wordToBreak != null;
    final correctParts = widget.lesson.correctOption?.split(',');

    if (isBreakMode) {
      // Break-word slots use the dedicated BreakWordDragSlot widget
      final slot = BreakWordDragSlot(
        droppedItem: _droppedItems[index],
        hasChecked: widget.hasChecked,
        isDarkMode: isDarkMode,
        optionButtonHeight: optionButtonHeight,
        optionFontFamily: widget.lesson.optionFontFamily,
        optionFontSize: widget.lesson.optionFontSize,
        onItemDropped: (item) {
          setState(() {
            _droppedItems[index] = item;
          });
          if (!_droppedItems.contains(null)) {
            widget.onOptionSelected?.call(_droppedItems.join(','));
          }
        },
        onItemRemoved: () {
          setState(() {
            _droppedItems[index] = null;
          });
          widget.onOptionSelected?.call(null);
        },
      );
      return expand ? Expanded(child: slot) : slot;
    }

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
          final droppedButton = Button(
            label: _droppedItems[index]!,
            size: ButtonSize.md,
            type: ButtonType.secondary,
            height: optionButtonHeight,
            iconSize: 24.0,
            borderRadius: BorderRadius.circular(16),
            textStyle: AppTextStyles.boldSm.copyWith(
              fontFamily: widget.lesson.optionFontFamily,
              fontSize: widget.lesson.optionFontSize,
            ),
            customBackgroundColor: isDarkMode
                ? AppColors.gray90
                : AppColors.primary20,
            customForegroundColor: AppColors.primary100,
            onTap: widget.hasChecked
                ? null
                : () {
                    setState(() {
                      _droppedItems[index] = null;
                    });
                    widget.onOptionSelected?.call(null);
                  },
          );

          return SizedBox(
            height: optionButtonHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  droppedButton,
                  Positioned(
                    left: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 12,
                        height: optionButtonHeight,
                        decoration: BoxDecoration(
                          color: AppColors.primary30,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (row) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: row == 4 ? 0 : 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildGripDot(),
                                    const SizedBox(width: 3),
                                    _buildGripDot(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox(height: optionButtonHeight, child: const EmptySlot());
      },
    );

    if (!expand) {
      return dragTarget;
    }

    return Expanded(child: dragTarget);
  }
}
