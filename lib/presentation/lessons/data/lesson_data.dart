import 'package:baybai/presentation/lessons/models/lesson_content.dart';
import 'package:flutter/material.dart';

class LessonData {
  static Map<int, List<LessonContent>> lessons = {
    1: [
      LessonContent(
        title: "What is Baybayin?",
        description:
            "Baybayin is an ancient Filipino writing system. Each symbol represents a **sound**, not just a letter. Lets start with the basic sounds.",
        image: "assets/images/lesson1_image1.png",
      ),
      LessonContent(
        title: "First Vowel",
        description:
            "It is the first vowel symbol in Baybayin. It is read as **'A'**.",
        image: "assets/images/lesson1_image2.png",
      ),
      LessonContent(
        title: "Second Vowel",
        description:
            "It makes the sound **'I' or 'E'** , Depending on the word",
        image: "assets/images/lesson1_image3.png",
      ),
      LessonContent(
        title: "Third Vowel",
        description:
            "The last vowel of symbol of Baybayin. It is read as **'O' or 'U'** ",
        image: "assets/images/lesson1_image4.png",
      ),
      LessonContent(
        title: "Quick Check",
        description: "Which one is **'A'**?",
        image: "assets/images/lesson1_image5.png",
        imageHeight: 200,
        imageFit: BoxFit.contain,
        options: ["\u1700", "\u1701", "\u1702"],
        correctOption: "\u1700",
      ),
      LessonContent(
        title: "First Consonant",
        description:
            "It makes the sound **'BA'**. In Baybayin, consonant already include the 'A' sound.",
        image: "assets/images/lesson1_image6.png",
      ),
      LessonContent(
        title: "More Consonants",
        description:
            "These are some consonants symbols in Baybayin. Each one already includes the **'A'** sound, so you read them as KA,MA, and BA.",
        image: "assets/images/lesson1_image7.png",
        imageFit: BoxFit.contain,
      ),
      LessonContent(
        title: "Quick Practice",
        description: "Which one is **'MA'**?",
        image: "assets/images/lesson1_image5.png",
        imageHeight: 200,
        imageFit: BoxFit.contain,
        options: ["\u170A", "\u1703", "\u170B"],
        correctOption: "\u170B",
      ),
      LessonContent(
        title: "Congratulations",
        description:
            "You've completed the lesson. You learned about the vowels, Basic Sound. Next you'll learn how to change sound using marks",
        image: "assets/images/lesson1_image8.png",
        imageFit: BoxFit.contain,
        iconPath: "assets/icons/confetti.svg",
      ),
    ],
    2: [
      LessonContent(
        title: "Review",
        description:
            "Each consonant already has **'A'** sound. But what if we want to change the sound? Let's learn how. ",
        image: "assets/images/lesson1_image7.png",
      ),
      LessonContent(
        title: "Changing Sounds",
        description:
            "In Baybayin, we use small marks called **kudlit**. These marks change the vowel sound of a character. They are placed **Above** and **Below** on Characters",
        image: "assets/images/lesson2_image1.png",
      ),
      LessonContent(
        title: "Kudlit Above",
        description:
            "When you place a mark **above** the character. the sound changes to **'E' or 'I'**. Example the Image above which the character **'BA'** with a kudlit above becomes **'BE'** or **'BI'**.",
        image: "assets/images/lesson2_image2.png",
      ),
      LessonContent(
        title: "Kudlit Below",
        description:
            "When you place a mark **below** the character. the sound changes to **'O' or 'U'**. Example the Image above which the character **'BA'** with a kudlit below becomes **'BO'** or **'BU'**.",
        image: "assets/images/lesson2_image3.png",
      ),
      LessonContent(
        title: "Quick Practice",
        description: "Which one the sound of this?",
        image: "assets/images/lesson1_image5.png",
        imageHeight: 200,
        imageFit: BoxFit.contain,
        options: ["KA", "Ki", "KO"],
        correctOption: "Ki",
        optionFontSize: 18,
        optionFontFamily: 'Poppins',
        optionLabels: ["\u170A", "\u170A\u1732", "\u170A\u1733"],
        labelFontSize: 20,
        labelFontFamily: 'Baybayin',
      ),
      LessonContent(
        title: "Another Practice",
        image: "assets/images/lesson1_image5.png",
        description: "Which one the sound of this?",
        imageHeight: 200,
        imageFit: BoxFit.contain,
        options: ["MA", "MI", "MO"],
        correctOption: "MI",
        optionFontSize: 18,
        optionFontFamily: 'Poppins',
        optionLabels: ["\u170B", "\u170B\u1732", "\u170B\u1733"],
        labelFontSize: 20,
        labelFontFamily: 'Baybayin',
      ),
      LessonContent(
        title: "Build the Sound",
        image: "assets/images/lesson1_image5.png",
        description: "Which one represent this **'BI'**?",
        imageHeight: 200,
        imageFit: BoxFit.contain,
        options: ["\u170A", "\u1703", "\u170B"],
        correctOption: "\u170B",
      ),

      LessonContent(
        title: "Congratulations",
        description: "You learned how to change the Sounds.",
        image: "assets/images/lesson1_image8.png",
        iconPath: "assets/icons/confetti.svg",
      ),
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
        iconPath: "assets/icons/confetti.svg",
      ),
    ],
  };
}
