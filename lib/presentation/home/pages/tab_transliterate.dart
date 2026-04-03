import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/presentation/home/widgets/transliteratecard.dart";
import "package:flutter/material.dart";

class TabTransliterate extends StatefulWidget {
  const TabTransliterate({super.key});

  @override
  State<TabTransliterate> createState() => _TabTransliterateState();
}

class _TabTransliterateState extends State<TabTransliterate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Row(children: [Expanded(child: TransliterateCard())]),
      ),
    );
  }
}
