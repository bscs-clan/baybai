class QuizQuestion {
  final String difficulty;
  final String question;
  final List<String> options;
  final String answer;

  const QuizQuestion({
    required this.difficulty,
    required this.question,
    required this.options,
    required this.answer,
  });
}

const List<QuizQuestion> quizQuestionBank = [
  QuizQuestion(
    difficulty: "Easy",
    question: "What kind of writing system is Baybayin?",
    options: [
      "An alphabet",
      "An abugida",
      "A number system",
      "A picture language",
    ],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does each basic Baybayin character represent?",
    options: [
      "A single consonant only",
      "A whole sentence",
      "A syllable",
      "A punctuation mark",
    ],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What vowel sound is included by default in a base consonant?",
    options: ["A", "E", "I", "O"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "How is the Baybayin character with \u170A read?",
    options: ["Ka", "Ma", "Ba", "Sa"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "Which sound does the character with \u1703 represent?",
    options: ["Ba", "Ka", "Pa", "Ta"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "Which sound does the character with \u170B represent?",
    options: ["Ma", "Na", "La", "Ya"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "Which sound does the character with \u1710 represent?",
    options: ["Ha", "Sa", "Wa", "Ra"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which Baybayin vowel character represents the sound A?",
    options: ["\u1700", "\u1701", "\u1702", "\u1703"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which vowel sounds share one Baybayin character?",
    options: ["A and O", "A and E", "I and E", "O and A"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which other pair of vowel sounds shares one Baybayin character?",
    options: ["O and U", "A and I", "E and O", "A and U"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What is the main rule for writing a word in Baybayin?",
    options: [
      "Copy every English letter",
      "Write the word's pronunciation",
      "Remove every vowel",
      "Write only the first syllable",
    ],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "How many syllables are in the word bata?",
    options: ["One", "Two", "Three", "Four"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which syllable breakdown matches bahay in the lesson plan?",
    options: ["ba-ha-y", "bah-ay", "ba-hay", "b-a-h-a-y"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "Which word is used in the lesson plan as an example of sound-based writing?",
    options: ["Photo", "Garden", "Window", "School"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "How is city represented by its pronunciation in the lesson plan?",
    options: ["ki-ti", "si-ti", "sa-ti", "si-ta"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which word is listed for the sound breakdown activity?",
    options: ["Bundok", "Lapis", "Tubig", "Araw"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which word is another example in the sound breakdown activity?",
    options: ["Pamilya", "Sapatos", "Kaibigan", "Bintana"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which statement best describes Baybayin in the lesson plan?",
    options: [
      "It writes sounds rather than exact spelling",
      "It uses one character for every English letter",
      "It has no vowel sounds",
      "It is a number system",
    ],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u1709 represent?",
    options: ["Pa", "Ba", "Ka", "Ma"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u1706 represent?",
    options: ["Da", "Ta", "Na", "La"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u1708 represent?",
    options: ["Nga", "Na", "Ga", "Ha"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u1704 represent?",
    options: ["Ga", "Ka", "Ba", "Sa"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u1705 represent?",
    options: ["Na", "Nga", "Ma", "Ya"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u170C represent?",
    options: ["La", "Ya", "Wa", "Ha"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u170E represent?",
    options: ["La", "Ra", "Sa", "Pa"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u170F represent?",
    options: ["Wa", "Ya", "Ha", "Da"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "What does the base character \u1711 represent?",
    options: ["Sa", "Ha", "Ga", "Ta"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "Which pair of sounds can be represented by the vowel character \u1701?",
    options: ["I and E", "O and U", "A and I", "A and O"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question:
        "Which pair of sounds can be represented by the vowel character \u1702?",
    options: ["I and E", "A and E", "O and U", "A and U"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Easy",
    question: "Which phrase is the key teaching quote in the lesson plan?",
    options: [
      "\"Write what you hear.\"",
      "\"Write every letter.\"",
      "\"Read without sound.\"",
      "\"Remove the vowels.\"",
    ],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "What does a top kudlit change the vowel sound to?",
    options: ["A", "I or E", "O or U", "No vowel"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "What does a bottom kudlit change the vowel sound to?",
    options: ["I or E", "A", "O or U", "No vowel"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which baybayin represents the top kudlit mark used for the I or E sound?",
    options: ["\u1712", "\u1713", "\u1714", "\u1700"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which baybayin represents the bottom kudlit mark used for the O or U sound?",
    options: ["\u1712", "\u1713", "\u1714", "\u1701"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "How is the base character \u170A read without a kudlit?",
    options: ["Ba", "Bi", "Bo", "B"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "How is \u170A with the top kudlit \u1712 read?",
    options: ["Ba", "Bi or Be", "Bo or Bu", "B"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "How is \u170A with the bottom kudlit \u1713 read?",
    options: ["Ba", "Bi or Be", "Bo or Bu", "B"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "What does the virama or pamudpod do?",
    options: [
      "Changes A to I",
      "Changes A to O",
      "Removes the default A vowel",
      "Adds another syllable",
    ],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "Which baybayin represents the virama or pamudpod?",
    options: ["\u1712", "\u1713", "\u1714", "\u1702"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "How is \u170A read when the virama is added?",
    options: ["Ba", "Bi", "Bo", "B"],
    answer: "D",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "What is a common feature of traditional Baybayin described in the lesson plan?",
    options: [
      "Final consonants are often omitted",
      "Every final consonant uses virama",
      "All vowels are removed",
      "Words are written in English spelling",
    ],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "What does modern Baybayin use for clearer final consonants?",
    options: ["Top kudlit", "Virama", "A second vowel", "A space"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "In the lesson plan, how is bundok represented in the traditional form?",
    options: ["bun-dok", "bu-do", "bo-dok", "ba-dok"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "In the lesson plan, how is bundok represented in the modern form?",
    options: ["bu-do", "ba-dok", "bun-dok", "bo-dok"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "In the lesson plan, how is anak represented in the traditional form?",
    options: ["a-na", "a-nak", "an-ak", "a-ka"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "Which sound does the base consonant \u1703 contain by default?",
    options: ["Ka", "Ga", "Ba", "Ta"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which reading can the combination \u170B with a bottom kudlit have?",
    options: ["Mi or Me", "Mu or Mo", "Ma only", "M without a vowel"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which reading can the combination \u1708 with a top kudlit have?",
    options: ["Na only", "No or Nu", "Ni or Ne", "N without a vowel"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which activity asks learners to change a given syllable using a kudlit?",
    options: [
      "Sound breakdown",
      "Add the correct kudlit",
      "Alphabet comparison",
      "Silent letter review",
    ],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "Which change uses a top kudlit?",
    options: ["Ba to Bi", "Ma to Mo", "Sa to So", "Ka to Ku"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "Which change uses a bottom kudlit?",
    options: ["Ba to Be", "Ma to Mi", "Ma to Mo", "Sa to Se"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Why can one kudlit reading sometimes have two possible vowel sounds?",
    options: [
      "Baybayin combines I with E and O with U",
      "Baybayin has no consonants",
      "The mark removes the syllable",
      "Every word has two vowels",
    ],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which statement about the sounds I and E matches the lesson plan?",
    options: [
      "They always use separate Baybayin vowel characters",
      "They share one sound family",
      "They are represented by virama",
      "They are silent",
    ],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which statement about the sounds O and U matches the lesson plan?",
    options: [
      "They share one sound family",
      "They use the top kudlit",
      "They are always omitted",
      "They are consonants",
    ],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "A learner wants the syllable \"be\" from the base syllable \"ba\". Which mark should be used?",
    options: ["Bottom kudlit", "Virama", "Top kudlit", "No mark"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "A learner wants the syllable \"bu\" from the base syllable \"ba\". Which mark should be used?",
    options: ["Top kudlit", "Bottom kudlit", "Virama", "No mark"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "A learner wants the final consonant sound \"k\" after a Baybayin base character. Which mark is used in modern Baybayin?",
    options: ["Top kudlit", "Bottom kudlit", "Virama", "Vowel A"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question: "What is the result of adding virama to a base consonant?",
    options: [
      "The default A is removed",
      "The sound changes to I",
      "The sound changes to O",
      "The consonant becomes a vowel",
    ],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which pair correctly matches the lesson plan's traditional and modern approaches?",
    options: [
      "Traditional uses virama; modern omits final consonants",
      "Traditional often omits final consonants; modern uses virama",
      "Both always omit final consonants",
      "Both use only kudlit marks",
    ],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Medium",
    question:
        "Which example shows the sound \"bo\" or \"bu\" using a bottom kudlit?",
    options: ["\u170A\u1712", "\u170A\u1713", "\u170A\u1714", "\u170A"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question:
        "According to the lesson plan, which sound is used to adapt the English letter F?",
    options: ["B", "P", "S", "T"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the word family adapted in the lesson plan?",
    options: ["bamily", "pamily", "famili", "pamili"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the word coffee adapted in the lesson plan?",
    options: ["kofi", "kopi", "sopi", "pofi"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "Which sound is used to adapt the English letter V?",
    options: ["B", "P", "S", "H"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is Vanessa adapted in the lesson plan?",
    options: ["Fanesa", "Banesa", "Vanesa", "Panesa"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "Which sound is used to adapt the English letter Z?",
    options: ["K", "T", "S", "DY"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the word zebra adapted in the lesson plan?",
    options: ["sebra", "zebra", "kebra", "sifra"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "What sound does a hard C have in the patterns CA, CO, and CU?",
    options: ["S", "K", "H", "T"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is cat adapted using the hard C rule?",
    options: ["sat", "kat", "chat", "tat"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "What sound does a soft C have before E or I in the lesson plan?",
    options: ["K", "P", "S", "DY"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is city adapted using the soft C rule?",
    options: ["kity", "siti", "sati", "sitiya"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the English-style J sound adapted in the lesson plan?",
    options: ["H", "DY", "Y", "S"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is jeep adapted in the lesson plan?",
    options: ["heep", "yip", "dyip", "jip"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is Spanish-style J adapted in the lesson plan?",
    options: ["DY", "H", "K", "S"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the name Jose adapted in the lesson plan?",
    options: ["Dyose", "Hose", "Sose", "Kose"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the word queso adapted in the lesson plan?",
    options: ["kweso", "keso", "kiso", "kuso"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "Which QU pattern is listed as having the sound KWA?",
    options: ["QUA", "QUE", "QUI", "QUO"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "Which QU pattern is listed as having the sound KI?",
    options: ["QUA", "QUE", "QUI", "QUU"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is the word queen adapted in the lesson plan?",
    options: ["kwin", "kin", "ken", "kwen"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "What sound is used to represent Ñ in the lesson plan?",
    options: ["NY", "DY", "KS", "SH"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is piña adapted in the lesson plan?",
    options: ["pina", "pinya", "piya", "pinga"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is año adapted in the lesson plan?",
    options: ["anyo", "ano", "anyoha", "anoya"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "What sound is used to represent X in the lesson plan?",
    options: ["CH", "KS", "S", "Z"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is taxi adapted in the lesson plan?",
    options: ["tasi", "takshi", "taksi", "taki"],
    answer: "C",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "Which pair of letter groups and sounds matches the lesson plan?",
    options: [
      "PH becomes T and TH becomes P",
      "PH becomes P and TH becomes T",
      "PH becomes F and TH becomes H",
      "PH becomes B and TH becomes D",
    ],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is photo adapted in the lesson plan?",
    options: ["foto", "poto", "boto", "toto"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is thesis adapted in the lesson plan?",
    options: ["tisis", "disis", "thesis", "pisis"],
    answer: "A",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question:
        "Which word is an example of a silent-letter adaptation in the lesson plan?",
    options: ["table", "knight", "market", "paper"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question: "How is island adapted in the lesson plan?",
    options: ["island", "ayland", "ailand", "islan"],
    answer: "B",
  ),
  QuizQuestion(
    difficulty: "Hard",
    question:
        "Which statement best describes how foreign sounds are handled in Baybayin?",
    options: [
      "Foreign sounds are approximated using nearest sound equivalents",
      "Every foreign letter gets a new Baybayin character",
      "Foreign words must keep their original spelling",
      "Only silent letters are changed",
    ],
    answer: "A",
  ),
];
