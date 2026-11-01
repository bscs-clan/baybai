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
  final String? audioAsset;
  final bool disablePlayback;

  const WordSoundTableItem({
    required this.word,
    required this.sound,
    this.audioAsset,
    this.disablePlayback = false,
  });
}

class SoundTableItem {
  final String spelling;
  final String sound;
  final String? audioAsset;
  final bool disablePlayback;

  const SoundTableItem({
    required this.spelling,
    required this.sound,
    this.audioAsset,
    this.disablePlayback = false,
  });
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
  final bool playSoundTableMappings;
  final bool playSoundTableExamples;
  final bool soundTableExamplesOnlyAudio;
  final bool boldSoundTableMappings;
  final int boldSoundTableMappingPrefixLength;
  final int boldSoundTableMappingSoundPrefixLength;
  final bool boldSoundTableExampleMappings;
  final bool boldSoundTableXKSExamples;
  final bool boldSoundTableNYExamples;
  final bool boldSoundTableAudioP;
  final bool showFinalConsonantCard;
  final String? soundTableTitle;
  final bool boldSoundTableFP;
  final bool boldSoundTableVBExamples;
  final List<SoundTableItem>? soundTableMappings;
  final List<SoundTableItem>? soundTableExamples;
  final bool showVowelSoundTableCard;
  final bool showKudlitTableCard;
  final bool showViramaTableCard;
  final bool showViramaQuestionMark;
  final bool playViramaAudio;
  final String? viramaBaseSymbol;
  final String? viramaBaseSound;
  final bool showSharedKudlitVowelCard;
  final bool showStrokeDemoCard;
  final bool showWordCard;
  final bool showWordCardAudio;
  final bool showAnswerBox;
  final bool showTextInput;
  final String? wordCardText;
  final String? audioAsset;
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
    this.playSoundTableMappings = false,
    this.playSoundTableExamples = false,
    this.soundTableExamplesOnlyAudio = false,
    this.boldSoundTableMappings = false,
    this.boldSoundTableMappingPrefixLength = 0,
    this.boldSoundTableMappingSoundPrefixLength = 0,
    this.boldSoundTableExampleMappings = false,
    this.boldSoundTableXKSExamples = false,
    this.boldSoundTableNYExamples = false,
    this.boldSoundTableAudioP = true,
    this.showFinalConsonantCard = false,
    this.soundTableTitle,
    this.boldSoundTableFP = true,
    this.boldSoundTableVBExamples = false,
    this.soundTableMappings,
    this.soundTableExamples,
    this.showVowelSoundTableCard = false,
    this.showKudlitTableCard = false,
    this.showViramaTableCard = false,
    this.showViramaQuestionMark = false,
    this.playViramaAudio = false,
    this.viramaBaseSymbol,
    this.viramaBaseSound,
    this.showSharedKudlitVowelCard = false,
    this.showStrokeDemoCard = false,
    this.showWordCard = false,
    this.showWordCardAudio = true,
    this.showAnswerBox = false,
    this.showTextInput = false,
    this.wordCardText,
    this.audioAsset,
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
