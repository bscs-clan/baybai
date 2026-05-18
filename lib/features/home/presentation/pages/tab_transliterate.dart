import "package:flutter/material.dart";
import "package:baybai/features/home/presentation/widgets/transliterate_card.dart";

class TabTransliterate extends StatefulWidget {
  const TabTransliterate({super.key});

  @override
  State<TabTransliterate> createState() => _TabTransliterateState();
}

class _TabTransliterateState extends State<TabTransliterate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Row(children: [Expanded(child: TransliterateCard())]),
      ),
    );
  }
}
