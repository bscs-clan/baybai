import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class LessonData {
  static const List<BaybyainSymbolData> basicSymbols = [
    BaybyainSymbolData(unicode: "\u1703", romanization: "KA"),
    BaybyainSymbolData(unicode: "\u170A", romanization: "BA"),
    BaybyainSymbolData(unicode: "\u170B", romanization: "MA"),
    BaybyainSymbolData(unicode: "\u1708", romanization: "NA"),
  ];

  static const List<String> countOptions = ["1", "2", "3", "4"];

  static const List<LessonMetadata> lessonList = [
    LessonMetadata(
      id: 1,
      number: "Lesson 1",
      title: "Understanding Baybayin",
    ),
    LessonMetadata(
      id: 2,
      number: "Lesson 2",
      title: "Baybayin Characters",
    ),
    LessonMetadata(
      id: 3,
      number: "Lesson 3",
      title: "The Kudlit Mark",
    ),
  ];

  static final Map<int, List<LessonContent>> lessons = {
    1: [
      LessonContent(
        title: "Welcome to Baybayin",
        description:
            "Baybayin is an ancient Filipino writing system. Instead of writing individual letters like English, Baybayin writes sounds.",
        symbols: basicSymbols,
        symbolsTitle: "Baybayin Symbols",
      ),
      soundComparison(
        title: "Baybayin Uses Sounds",
        description: "One symbol already contains a sound.",
        englishFirst: "b",
        englishSecond: "a",
        englishResult: "ba",
        baybayinSymbol: "\u170A",
        baybayinResult: "ba",
      ),
      soundComparisonList(
        title: "Look at these examples",
        description: "Each symbol already has the vowel **a**.",
        comparisons: [
          baybayinSound("\u170A", "ba"),
          baybayinSound("\u1703", "ka"),
          baybayinSound("\u170B", "ma"),
        ],
      ),
      soundCheck(
        baybayinText: "\u170A",
        options: ["b", "a", "ba", "ab"],
        correctOption: "ba",
      ),
      soundCheck(
        baybayinText: "\u170B",
        options: ["a", "ma", "am", "m"],
        correctOption: "ma",
      ),
      soundCheck(
        baybayinText: "\u1703",
        options: ["ka", "a", "k", "ak"],
        correctOption: "ka",
      ),
      wordBreakdown(
        title: "Let's Read Together",
        description: "Baybayin reads words through sounds, not letters.",
        word: "bata",
        syllables: ["ba", "ta"],
        baybayinSyllables: ["\u170A", "\u1706"],
        meaning: "child",
      ),
      syllableCountCheck(baybayinText: "mata", correctOption: "2"),
      wordBreakdown(
        title: "Another Example",
        description: "Baybayin reads words through sounds, not letters.",
        word: "baka",
        syllables: ["ba", "ka"],
        baybayinSyllables: ["\u170A", "\u1703"],
        meaning: "cow",
      ),
      syllableCountCheck(baybayinText: "Kama", correctOption: "2"),
      complete("You learned how to read simple words!"),
    ],
    2: [
      LessonContent(
        title: "Meet the Baybayin characters",
        description:
            "Now that you know Baybayin writes sounds, it's time to learn the symbols. Each symbol represents a sound, not a single letter.",
        symbols: basicSymbols,
        symbolsTitle: "Baybayin Symbols",
      ),
      soundComparisonList(
        title: "The Three Vowels",
        description:
            "Baybayin has three vowel symbols. These are the building blocks of many words.",
        comparisons: [
          baybayinSound("\u1700", "a"),
          baybayinSound("\u1701", "e / i"),
          baybayinSound("\u1702", "o / u"),
        ],
      ),
      vowelSymbolCheck(
        vowel: "a",
        options: ["\u1703", "\u1702", "\u1700", "\u1701"],
        correctOption: "\u1700",
      ),
      vowelSymbolCheck(
        vowel: "e / i",
        options: ["\u1702", "\u1701", "\u170A", "\u1700"],
        correctOption: "\u1701",
      ),
      vowelSymbolCheck(
        vowel: "o / u",
        options: ["\u1700", "\u170B", "\u1702", "\u1701"],
        correctOption: "\u1702",
      ),
      soundComparisonList(
        title: "Baybayin Consonant",
        description:
            "This is one of the most important Baybayin rules. When you see a consonant symbol, it already contains the vowel **a**.",
        comparisons: [
          baybayinSound("\u170A", "ba"),
          baybayinSound("\u1703", "ka"),
          baybayinSound("\u170B", "ma"),
        ],
      ),
      consonantSymbolCheck(
        consonant: "ba",
        options: ["\u1703", "\u170A", "\u170B", "\u1708"],
        correctOption: "\u170A",
      ),
      soundComparisonList(
        title: "More examples",
        description: "Notice that every symbol ends with **a**",
        comparisons: [
          baybayinSound("\u170C", "ya"),
          baybayinSound("\u170D", "la"),
          baybayinSound("\u170F", "wa"),
        ],
      ),
      consonantSymbolCheck(
        consonant: "ya",
        options: ["\u170F", "\u170C", "\u170D", "\u170A"],
        correctOption: "\u170C",
      ),
      consonantSymbolCheck(
        consonant: "la",
        options: ["\u170B", "\u170F", "\u170D", "\u170C"],
        correctOption: "\u170D",
      ),
      consonantSymbolCheck(
        consonant: "wa",
        options: ["\u170D", "\u1703", "\u170F", "\u170C"],
        correctOption: "\u170F",
      ),
       wordBreakdown(
        title: "Let's Read Together",
        description: "Baybayin reads words through sounds, not letters.",
        word: "tama",
        syllables: ["ta", "ma"],
        baybayinSyllables: ["\u1706", "\u170B"],
        meaning: "correct",
      ),
      syllableCountCheck(baybayinText: "mata", correctOption: "2"),
      wordBreakdown(
        title: "Another Example",
        description: "Baybayin reads words through sounds, not letters.",
        word: "kama",
        syllables: ["ka", "ma"],
        baybayinSyllables: ["\u1703", "\u170B"],
        meaning: "bed",
      ),
      syllableCountCheck(baybayinText: "gata", correctOption: "2"),
      complete("You Learn Baybayin basics!"),
    ],
    3: [
      LessonContent(
        title: "The Kudlit Mark",
        description:
            "Learn how to change the vowel sound using the Kudlit mark.",
        image: "assets/images/lesson1_image1.png",
      ),
      LessonContent(
        title: "Top Kudlit",
        description: "A kudlit on top changes the sound to 'E' or 'I'.",
        image: "assets/images/lesson1_image3.png",
      ),
      LessonContent(
        title: "Bottom Kudlit",
        description: "A kudlit at the bottom changes the sound to 'O' or 'U'.",
        image: "assets/images/lesson1_image4.png",
      ),
      LessonContent(
        title: "Congratulations",
        description: "You've finished Lesson 3!",
        image: "assets/images/lesson1_image8.png",
        icon: LessonIcon.confetti,
      ),
    ],
  };

  static LessonContent soundComparison({
    required String title,
    required String description,
    required String englishFirst,
    required String englishSecond,
    required String englishResult,
    required String baybayinSymbol,
    required String baybayinResult,
  }) {
    return LessonContent(
      title: title,
      description: description,
      soundComparison: SoundComparisonData(
        englishFirst: englishFirst,
        englishSecond: englishSecond,
        englishResult: englishResult,
        baybayinSymbol: baybayinSymbol,
        baybayinResult: baybayinResult,
      ),
    );
  }

  static LessonContent soundComparisonList({
    required String title,
    required String description,
    required List<SoundComparisonData> comparisons,
  }) {
    return LessonContent(
      title: title,
      description: description,
      soundComparisons: comparisons,
    );
  }

  static SoundComparisonData baybayinSound(
    String baybayinSymbol,
    String baybayinResult,
  ) {
    return SoundComparisonData(
      englishFirst: "",
      englishSecond: "",
      englishResult: "",
      baybayinSymbol: baybayinSymbol,
      baybayinResult: baybayinResult,
    );
  }

  static LessonContent soundCheck({
    required String baybayinText,
    required List<String> options,
    required String correctOption,
  }) {
    return LessonContent(
      title: "Quick Check",
      description: "What sound does the symbol make?",
      baybayinText: baybayinText,
      options: options,
      correctOption: correctOption,
    );
  }

  static LessonContent vowelSymbolCheck({
    required String vowel,
    required List<String> options,
    required String correctOption,
  }) {
    return LessonContent(
      title: "Quick Check",
      description: "Which symbol represents this vowel?",
      baybayinText: vowel,
      baybayinFontFamily: "Poppins",
      baybayinFontSize: 56,
      options: options,
      optionFontFamily: "Baybayin",
      optionFontSize: 36,
      correctOption: correctOption,
    );
  }

  static LessonContent consonantSymbolCheck({
    required String consonant,
    required List<String> options,
    required String correctOption,
  }) {
    return LessonContent(
      title: "Quick Check",
      description: "Which symbol represents this consonant?",
      baybayinText: consonant,
      baybayinFontFamily: "Poppins",
      baybayinFontSize: 56,
      options: options,
      optionFontFamily: "Baybayin",
      optionFontSize: 36,
      correctOption: correctOption,
    );
  }

  static LessonContent syllableCountCheck({
    required String baybayinText,
    required String correctOption,
  }) {
    return LessonContent(
      title: "Quick Check",
      description: "How many sound are in the word?",
      baybayinText: baybayinText,
      baybayinFontFamily: "Poppins",
      baybayinFontSize: 32,
      options: countOptions,
      correctOption: correctOption,
    );
  }

  static LessonContent wordBreakdown({
    required String title,
    required String description,
    required String word,
    required List<String> syllables,
    required List<String> baybayinSyllables,
    required String meaning,
  }) {
    return LessonContent(
      title: title,
      description: description,
      wordBreakdown: WordBreakdownData(
        word: word,
        syllables: syllables,
        baybayinSyllables: baybayinSyllables,
        meaning: meaning,
      ),
    );
  }

  static LessonContent complete(String description) {
    return LessonContent(title: "Lesson Complete!", description: description);
  }
}
