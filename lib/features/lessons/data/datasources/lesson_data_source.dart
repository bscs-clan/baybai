import "package:baybai/features/lessons/domain/entities/lesson_content.dart";

class LessonData {
  static const Map<int, List<LessonContent>> lessons = {
    1: [
      LessonContent(
        title: "One Baybayin symbol already represents a complete sound. ",
        showComparisonCard: true,
        description:
            "Unlike English, Baybayin isn't built from individual letters. Instead, it starts with **sounds**.",
      ),
      LessonContent(
        title: "Baybayin reads words one syllable at a time. ",
        showSyllableTableCard: true,
        description:
            "Instead of writing individual letters, Baybayin groups words into **syllables**.",
      ),
      LessonContent(
        title:
            "Now its your turn! Break the word into syllables by choosing the correct parts below.",
        wordToBreak: "GABI",
        options: ["GAB", "BI", "GA", "I"],
        correctOption: "GA,BI",
      ),
      LessonContent(
        title:
            "Break the word into syllables by choosing the correct parts below.",
        wordToBreak: "BAKA",
        options: ["BA", "BAK", "A", "KA"],
        correctOption: "BA,KA",
      ),
      LessonContent(
        title:
            "Choose the correct parts below to split the word into syllables.",
        wordToBreak: "BAHAY",
        options: ["BA", "HA", "HAY", "AY", "Y", "H"],
        correctOption: "BA,HA,Y",
        numSlots: 3,
      ),
      LessonContent(
        title:
            "Choose the correct parts below to split the word into syllables.",
        wordToBreak: "UMAGA",
        options: ["U", "MA", "G", "M", "GA", "A"],
        correctOption: "U,MA,GA",
        numSlots: 3,
      ),
      LessonContent(
        title: "Build the word by choosing the correct syllables below.",
        wordToBreak: "KAMUSTA",
        showAnswerBox: true,
        options: ["MU", "KA", "MUS", "STA", "TA", "KAM"],
        correctOption: "KA,MUS,TA",
      ),
      LessonContent(
        title: "Build the word by choosing the correct syllables below.",
        wordToBreak: "UMAGA",
        showAnswerBox: true,
        options: ["U", "MA", "GA", "UM", "AGA", "MAGA"],
        correctOption: "U,MA,GA",
      ),
      LessonContent(
        title: "Baybayin writes words the way they sound. ",
        showWordSoundTableCard: true,
        description:
            "Some words are spelled differently from how they sound. Baybayin follows the **sound** you hear, not how it **spelled**.",
      ),
      LessonContent(
        title: "Now which one sound is right.",
        showWordCard: true,
        wordCardText: "CAKE",
        options: ["KAYK", "KAKE", "KEK", "KEYK"],
        correctOption: "KEYK",
      ),
      LessonContent(
        title: "which one sound is right.",
        showWordCard: true,
        wordCardText: "PHOTO",
        options: ["POTO", "PHOTO", "FOTO", "PATO"],
        correctOption: "POTO",
      ),
      LessonContent(
        title: "which one sound is right.",
        showWordCard: true,
        wordCardText: "COFFEE",
        options: ["KOFE", "KAPE", "COPI", "CUFI"],
        correctOption: "COPI",
      ),
    ],
    2: [
      LessonContent(
        title: "Let's meet your first Baybayin characters.",
        showCharacterSoundTableCard: true,
        description:
            "Every base character already includes the vowel **'a'**. That means you don't read them as b, k, or m. You read them as ba, ka, and ma.",
      ),
      LessonContent(
        title: "Drag the sounds to their matching characters.",
        matchCharacters: ["\u170A", "\u1703"],
        options: ["ba", "ka"],
        correctOption: "ba,ka",
      ),
      LessonContent(
        title: "What sound does this character make?",
        baybayinText: "\u170A",
        showQuizTable: true,
        options: ["ba", "ka", "ma", "sa"],
        correctOption: "ba",
      ),
      LessonContent(
        title: "The same pattern works for every base character",
        showCharacterSoundTableCard: true,
        characterSoundItems: [
          LessonCardItem(text: "Da", baybayinSymbol: "\u1707"),
          LessonCardItem(text: "Ga", baybayinSymbol: "\u1704"),
          LessonCardItem(text: "Ha", baybayinSymbol: "\u1711"),
          LessonCardItem(text: "La", baybayinSymbol: "\u170E"),
        ],
        description: "You don't need to add the 'a'. It's already there.",
      ),
      LessonContent(
        title: "Drag the sounds to their matching characters.",
        matchCharacters: ["\u170B", "\u1703", "\u170A"],
        options: ["ka", "ma", "ba"],
        correctOption: "ma,ka,ba",
      ),
      LessonContent(
        title: "What sound does this character make?",
        baybayinText: "\u1703",
        showQuizTable: true,
        options: ["ma", "ba", "ka", "sa"],
        correctOption: "ka",
      ),
      LessonContent(
        title: "Baybayin has its own vowel symbols too.",
        showVowelSoundTableCard: true,
        description: "Some vowels share the same symbol.",
      ),
      LessonContent(
        title: "Drag the sounds to their matching characters.",
        matchCharacters: ["\u1702", "\u1701"],
        options: ["o / u", "e / i"],
        correctOption: "o / u,e / i",
      ),
      LessonContent(
        title: "What sound does this character make?",
        baybayinText: "\u1700",
        showQuizTable: true,
        options: ["a", "ma", "ka", "ha"],
        correctOption: "a",
      ),
      LessonContent(
        title: "What sound does this character make?",
        baybayinText: "\u170B",
        showQuizTable: true,
        options: ["ma", "ba", "ka", "sa"],
        correctOption: "ma",
      ),
      LessonContent(
        title: "Build the word by choosing the correct symbols below.",
        wordToBreak: "BAKA",
        options: ["\u1703", "\u170A", "\u1710", "\u170B"],
        correctOption: "\u170A,\u1703",
        optionFontFamily: "Baybayin",
        optionFontSize: 15,
        numSlots: 2,
      ),
    ],
    3: [
      LessonContent(
        title: "The kudlit mark changes a character's vowel sound.",
        showKudlitTableCard: true,
        description:
            "A kudlit is a small mark that you add to a base character to change its vowel sound.",
      ),
      LessonContent(
        title: "Add the correct kudlit to change the sound.",
        kudlitPracticeBaseSymbol: "\u170A",
        kudlitPracticeBaseSound: "ba",
        kudlitPracticeTargetSound: "bi",
        options: ["Top kudlit", "Bottom kudlit"],
        correctOption: "Top kudlit",
      ),
      LessonContent(
        title: "Add the correct kudlit to change the sound.",
        kudlitPracticeBaseSymbol: "\u170A",
        kudlitPracticeBaseSound: "ba",
        kudlitPracticeTargetSound: "bu",
        options: ["Top kudlit", "Bottom kudlit"],
        correctOption: "Bottom kudlit",
      ),
      LessonContent(
        title: "The same rule works for every base character.",
        showKudlitTableCard: true,
        kudlitTableItems: [
          KudlitTableItem(baseSymbol: "\u1703", mark: "No kudlit", sound: "ka"),
          KudlitTableItem(
            baseSymbol: "\u1703",
            kudlit: "\u1712",
            mark: "Top kudlit",
            sound: "ki / ke",
          ),
          KudlitTableItem(
            baseSymbol: "\u1703",
            kudlit: "\u1713",
            mark: "Bottom kudlit",
            sound: "ku / ko",
          ),
        ],
      ),
      LessonContent(
        title: "Add the correct kudlit to change the sound.",
        kudlitPracticeBaseSymbol: "\u1703",
        kudlitPracticeBaseSound: "ka",
        kudlitPracticeTargetSound: "ki",
        options: ["Top kudlit", "Bottom kudlit"],
        correctOption: "Top kudlit",
      ),
      LessonContent(
        title: "Add the correct kudlit to change the sound.",
        kudlitPracticeBaseSymbol: "\u1703",
        kudlitPracticeBaseSound: "ka",
        kudlitPracticeTargetSound: "ko",
        options: ["Top kudlit", "Bottom kudlit"],
        correctOption: "Bottom kudlit",
      ),
      LessonContent(
        title: "Some vowels share the same kudlit symbol.",
        showSharedKudlitVowelCard: true,
        description: "Context tells you which sound is correct.",
      ),
      LessonContent(
        title: "Choose the character that says this sound.",
        showWordCard: true,
        wordCardText: "be",
        options: [
          "\u170A\u1712",
          "\u170A\u1713",
          "\u1703\u1712",
          "\u1703\u1713",
        ],
        correctOption: "\u170A\u1712",
        optionFontFamily: "Baybayin",
        optionFontSize: 32,
        optionButtonHeight: 72,
      ),
      LessonContent(
        title: "Choose the character that says this sound.",
        showWordCard: true,
        wordCardText: "ko",
        options: [
          "\u170A\u1712",
          "\u170A\u1713",
          "\u1703\u1712",
          "\u1703\u1713",
        ],
        correctOption: "\u1703\u1713",
        optionFontFamily: "Baybayin",
        optionFontSize: 32,
        optionButtonHeight: 72,
      ),
    ],
  };

  static const List<LessonMetadata> lessonList = [
    LessonMetadata(
      id: 1,
      number: "Lesson 1",
      title: "Baybayin Basics",
      description: "Learn the basics of Baybayin and how words are written by sound.",
    ),
    LessonMetadata(
      id: 2,
      number: "Lesson 2",
      title: "Baybayin Characters",
      description:
          "Learn Baybayin characters, vowel symbols, and how each symbol maps to a sound.",
    ),
    LessonMetadata(
      id: 3,
      number: "Lesson 3",
      title: "The Kudlit Mark",
      description: "Learn how kudlit marks change a character's vowel sound.",
    ),
  ];
}
