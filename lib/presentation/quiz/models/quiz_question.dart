class QuizQuestion {
  final String imagePath;
  final String correctAnswer;
  final List<String> options;
  final String hint;

  const QuizQuestion({
    required this.imagePath,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });
}

final List<QuizQuestion> sampleQuestions = [
  QuizQuestion(
    imagePath: "assets/images/quiz_image1.png",
    correctAnswer: "A",
    options: ["A", "I", "U", "KA"],
    hint: "It's the first vowel in Baybayin.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image2.png",
    correctAnswer: "I/E",
    options: ["A", "I/E", "U/O", "GA"],
    hint: "This symbol represents both I and E sounds.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image3.png",
    correctAnswer: "U/O",
    options: ["I/E", "U/O", "MA", "NA"],
    hint: "This symbol represents both U and O sounds.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image4.png",
    correctAnswer: "KA",
    options: ["KA", "GA", "NGA", "TA"],
    hint: "The sound 'K' followed by 'A'.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image5.png",
    correctAnswer: "GA",
    options: ["KA", "GA", "DA", "LA"],
    hint: "The sound 'G' followed by 'A'.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image6.png",
    correctAnswer: "NGA",
    options: ["NA", "NGA", "MA", "YA"],
    hint: "A nasal sound common in Filipino.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image7.png",
    correctAnswer: "TA",
    options: ["TA", "DA", "NA", "PA"],
    hint: "The sound 'T' followed by 'A'.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image8.png",
    correctAnswer: "DA",
    options: ["TA", "DA", "LA", "RA"],
    hint: "The sound 'D' followed by 'A'.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image9.png",
    correctAnswer: "NA",
    options: ["NA", "MA", "NGA", "YA"],
    hint: "The sound 'N' followed by 'A'.",
  ),
  QuizQuestion(
    imagePath: "assets/images/quiz_image10.png",
    correctAnswer: "BA",
    options: ["PA", "BA", "MA", "WA"],
    hint: "The sound 'B' followed by 'A'.",
  ),
];
