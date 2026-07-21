import 'package:baybai/features/lessons/data/datasources/lesson_data_source.dart';
import 'package:baybai/features/lessons/domain/entities/lesson_content.dart';
import 'package:baybai/features/lessons/presentation/widgets/lesson_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lesson data includes a build-the-word slide after the UMAGA break slide', () {
    final lessons = LessonData.lessons[1]!;
    final umagaIndex = lessons.indexWhere((lesson) => lesson.wordToBreak == 'UMAGA');

    expect(umagaIndex, isNot(-1));

    final followUp = lessons[umagaIndex + 1];
    expect(followUp.showAnswerBox, isTrue);
    expect(followUp.options, containsAll(['U', 'MA', 'GA']));
    expect(followUp.correctOption, 'U,MA,GA');
  });

  testWidgets('answer box appears after selecting an option and hides again when tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonSlide(
            lesson: const LessonContent(
              title: 'Build the word',
              showAnswerBox: true,
              options: ['KA', 'MU', 'TA'],
              correctOption: 'KA,MU,TA',
            ),
            onOptionSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('answer-area')), findsNothing);

    await tester.tap(find.text('KA'));
    await tester.pump();

    expect(find.byKey(const ValueKey('answer-area')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('answer-area')));
    await tester.pump();

    expect(find.byKey(const ValueKey('answer-area')), findsNothing);
  });

  testWidgets('answer mode toggles an option off when tapped again', (
    WidgetTester tester,
  ) async {
    final selections = <String?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonSlide(
            lesson: const LessonContent(
              title: 'Build the word',
              showAnswerBox: true,
              options: ['KA', 'MU', 'TA'],
              correctOption: 'KA,MU,TA',
            ),
            onOptionSelected: selections.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('KA'));
    await tester.pump();
    await tester.tap(find.text('KA'));
    await tester.pump();

    expect(selections, ['KA', null]);
  });

  testWidgets('tapping a chip in the answer box removes that selection', (
    WidgetTester tester,
  ) async {
    final selections = <String?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonSlide(
            lesson: const LessonContent(
              title: 'Build the word',
              showAnswerBox: true,
              options: ['KA', 'MU', 'TA'],
              correctOption: 'KA,MU,TA',
            ),
            onOptionSelected: selections.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('KA'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('answer-piece-KA')));
    await tester.pump();

    expect(selections, ['KA', null]);
  });
}
