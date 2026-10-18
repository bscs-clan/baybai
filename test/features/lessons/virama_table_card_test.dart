import 'package:baybai/features/lessons/presentation/widgets/virama_table_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ViramaTableCard shows the requested virama labels by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ViramaTableCard())),
    );

    expect(find.text('\u170A'), findsOneWidget);
    expect(find.text('\u170A\u1714'), findsOneWidget);
    expect(find.text('ba'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('Without virama'), findsOneWidget);
    expect(find.text('With virama'), findsOneWidget);
    expect(find.text('The default vowel is present.'), findsNothing);
    expect(find.text('Virama removes the a vowel.'), findsNothing);
  });

  testWidgets('ViramaTableCard can show explanatory descriptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ViramaTableCard(showExplanations: true)),
      ),
    );

    expect(find.text('The default vowel is present.'), findsOneWidget);
    expect(find.text('Virama removes the a vowel.'), findsOneWidget);
  });
}
