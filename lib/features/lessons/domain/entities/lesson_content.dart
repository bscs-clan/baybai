enum LessonIcon { confetti }

class LessonMetadata {
  final int id;
  final String number;
  final String title;
  final String description;

  const LessonMetadata({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
  });
}

class LessonCardItem {
  final String text;
  final String baybayinSymbol;

  const LessonCardItem({required this.text, required this.baybayinSymbol});
}

class WordSoundTableItem {
  final String word;
  final String sound;

  const WordSoundTableItem({required this.word, required this.sound});
}

class SoundTableItem {
  final String spelling;
  final String sound;

  const SoundTableItem({required this.spelling, required this.sound});
}

class KudlitTableItem {
  final String baseSymbol;
  final String? kudlit;
  final String mark;
  final String sound;

  const KudlitTableItem({
    required this.baseSymbol,
    this.kudlit,
    required this.mark,
    required this.sound,
  });
}

class StrokeDemoItem {
  final String label;

  const StrokeDemoItem({required this.label});
}

class LessonContent {
  final String? title;
  final String baybayinText;
  final List<String>? options;
  final String? correctOption;
  final LessonIcon? icon;

  final double? baybayinFontSize;
  final double? optionFontSize;
  final double? optionButtonHeight;
  final String? baybayinFontFamily;
  final String? optionFontFamily;

  final List<LessonCardItem>? cardItems;
  final List<WordSoundTableItem>? wordSoundTableItems;
  final String? wordSoundTableFirstColumnTitle;
  final String? wordSoundTableSecondColumnTitle;
  final bool showComparisonCard;
  final bool showQuizTable;
  final bool showSyllableTableCard;
  final bool showWordSoundTableCard;
  final bool showCharacterSoundTableCard;
  final bool showSoundTableCard;
  final bool showFinalConsonantCard;
  final String? soundTableTitle;
  final List<SoundTableItem>? soundTableMappings;
  final List<SoundTableItem>? soundTableExamples;
  final bool showVowelSoundTableCard;
  final bool showKudlitTableCard;
  final bool showViramaTableCard;
  final bool showViramaExplanations;
  final bool showSharedKudlitVowelCard;
  final bool showStrokeDemoCard;
  final bool showWordCard;
  final bool showAnswerBox;
  final bool showTextInput;
  final String? wordCardText;
  final String? description;
  final String? wordToBreak;
  final String? kudlitPracticeBaseSymbol;
  final String? kudlitPracticeBaseSound;
  final String? kudlitPracticeTargetSound;
  final List<String>? matchCharacters;
  final List<LessonCardItem>? characterSoundItems;
  final List<LessonCardItem>? vowelSoundItems;
  final List<KudlitTableItem>? kudlitTableItems;
  final List<StrokeDemoItem>? strokeDemoItems;
  final int? numSlots;

  const LessonContent({
    this.title,
    this.baybayinText = "",
    this.options,
    this.correctOption,
    this.icon,
    this.baybayinFontSize,
    this.optionFontSize,
    this.optionButtonHeight,
    this.baybayinFontFamily,
    this.optionFontFamily,
    this.cardItems,
    this.wordSoundTableItems,
    this.wordSoundTableFirstColumnTitle,
    this.wordSoundTableSecondColumnTitle,
    this.showComparisonCard = false,
    this.showQuizTable = false,
    this.showSyllableTableCard = false,
    this.showWordSoundTableCard = false,
    this.showCharacterSoundTableCard = false,
    this.showSoundTableCard = false,
    this.showFinalConsonantCard = false,
    this.soundTableTitle,
    this.soundTableMappings,
    this.soundTableExamples,
    this.showVowelSoundTableCard = false,
    this.showKudlitTableCard = false,
    this.showViramaTableCard = false,
    this.showViramaExplanations = false,
    this.showSharedKudlitVowelCard = false,
    this.showStrokeDemoCard = false,
    this.showWordCard = false,
    this.showAnswerBox = false,
    this.showTextInput = false,
    this.wordCardText,
    this.description,
    this.wordToBreak,
    this.kudlitPracticeBaseSymbol,
    this.kudlitPracticeBaseSound,
    this.kudlitPracticeTargetSound,
    this.matchCharacters,
    this.characterSoundItems,
    this.vowelSoundItems,
    this.kudlitTableItems,
    this.strokeDemoItems,
    this.numSlots,
  });
}
