import 'package:baybai/features/lessons/domain/entities/lesson_content.dart';
import 'package:baybai/features/lessons/presentation/widgets/word_sound_table_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WordSoundTableCard shows custom headers and examples', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WordSoundTableCard(
            leftTitle: 'Foreign Word',
            rightTitle: 'Baybayin Sound',
            examples: [
              WordSoundTableItem(word: 'City', sound: 'Siti'),
              WordSoundTableItem(word: 'Photo', sound: 'Poto'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Foreign Word'), findsOneWidget);
    expect(find.text('Baybayin Sound'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Poto'), findsOneWidget);
  });
}
