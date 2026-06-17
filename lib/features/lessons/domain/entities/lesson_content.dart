enum LessonImageFit { cover, contain }

enum LessonIcon { confetti }

class LessonMetadata {
  final int id;
  final String number;
  final String title;

  const LessonMetadata({
    required this.id,
    required this.number,
    required this.title,
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

class BaybyainSymbolData {
  final String unicode;
  final String romanization;

  const BaybyainSymbolData({
    required this.unicode,
    required this.romanization,
  });
}

class SoundComparisonData {
  final String englishFirst;
  final String englishSecond;
  final String englishResult;
  final String baybayinSymbol;
  final String baybayinResult;

  const SoundComparisonData({
    required this.englishFirst,
    required this.englishSecond,
    required this.englishResult,
    required this.baybayinSymbol,
    required this.baybayinResult,
  });
}

class WordBreakdownData {
  final String word;
  final List<String> syllables;
  final String? meaning;
  final List<String>? baybayinSyllables;

  const WordBreakdownData({
    required this.word,
    required this.syllables,
    this.meaning,
    this.baybayinSyllables,
  });
}

class LessonContent {
  final String title;
  final String description;
  final String baybayinText;
  final String? image;
  final double? imageHeight;
  final double? imageWidth;
  final LessonImageFit imageFit;
  final List<String>? options;
  final List<String>? optionLabels;
  final String? correctOption;
  final LessonIcon? icon;
  final List<BaybyainSymbolData>? symbols;
  final String? symbolsTitle;
  final SoundComparisonData? soundComparison;
  final List<SoundComparisonData>? soundComparisons;
  final WordBreakdownData? wordBreakdown;

  final double? baybayinFontSize;
  final double? optionFontSize;
  final double? titleFontSize;
  final double? descriptionFontSize;
  final double? labelFontSize;
  final String? baybayinFontFamily;
  final String? optionFontFamily;
  final String? titleFontFamily;
  final String? descriptionFontFamily;
  final String? labelFontFamily;

  const LessonContent({
    required this.title,
    required this.description,
    this.baybayinText = "",
    this.image,
    this.icon,
    this.imageHeight,
    this.imageWidth,
    this.imageFit = LessonImageFit.cover,
    this.options,
    this.optionLabels,
    this.correctOption,
    this.symbols,
    this.symbolsTitle,
    this.soundComparison,
    this.soundComparisons,
    this.wordBreakdown,
    this.baybayinFontSize,
    this.optionFontSize,
    this.titleFontSize,
    this.descriptionFontSize,
    this.labelFontSize,
    this.baybayinFontFamily,
    this.optionFontFamily,
    this.titleFontFamily,
    this.descriptionFontFamily,
    this.labelFontFamily,
  });
}
