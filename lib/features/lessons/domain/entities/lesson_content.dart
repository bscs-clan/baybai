enum LessonImageFit { cover, contain }

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
    this.description =
        "Learn the basics of Baybayin and how words are written by sound.",
  });
}

class WrongAnswerInfo {
  final LessonContent question;
  final String selectedOption;
  final String correctOption;

  const WrongAnswerInfo({
    required this.question,
    required this.selectedOption,
    required this.correctOption,
  });
}

/// A single syllable-symbol pair shown inside an AppCard on content slides.
class LessonCardItem {
  final String text;
  final String baybayinSymbol;

  const LessonCardItem({required this.text, required this.baybayinSymbol});
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
  final String title;
  final String baybayinText;
  final String? image;
  final double? imageHeight;
  final double? imageWidth;
  final LessonImageFit imageFit;
  final List<String>? options;
  final List<String>? optionLabels;
  final String? correctOption;
  final LessonIcon? icon;

  final double? baybayinFontSize;
  final double? optionFontSize;
  final double? optionButtonHeight;
  final double? titleFontSize;
  final double? labelFontSize;
  final String? baybayinFontFamily;
  final String? optionFontFamily;
  final String? titleFontFamily;
  final String? labelFontFamily;

  final List<LessonCardItem>? cardItems;
  final bool showComparisonCard;
  final bool showQuizTable;
  final bool showSyllableTableCard;
  final bool showWordSoundTableCard;
  final bool showCharacterSoundTableCard;
  final bool showVowelSoundTableCard;
  final bool showKudlitTableCard;
  final bool showSharedKudlitVowelCard;
  final bool showStrokeDemoCard;
  final bool showWordCard;
  final bool showAnswerBox;
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
    required this.title,
    this.baybayinText = "",
    this.image,
    this.icon,
    this.imageHeight,
    this.imageWidth,
    this.imageFit = LessonImageFit.cover,
    this.options,
    this.optionLabels,
    this.correctOption,
    this.baybayinFontSize,
    this.optionFontSize,
    this.optionButtonHeight,
    this.titleFontSize,
    this.labelFontSize,
    this.baybayinFontFamily,
    this.optionFontFamily,
    this.titleFontFamily,
    this.labelFontFamily,
    this.cardItems,
    this.showComparisonCard = false,
    this.showQuizTable = false,
    this.showSyllableTableCard = false,
    this.showWordSoundTableCard = false,
    this.showCharacterSoundTableCard = false,
    this.showVowelSoundTableCard = false,
    this.showKudlitTableCard = false,
    this.showSharedKudlitVowelCard = false,
    this.showStrokeDemoCard = false,
    this.showWordCard = false,
    this.showAnswerBox = false,
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
