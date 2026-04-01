import 'package:baybai/components/theme/colors.dart';
import 'package:baybai/components/transliteratecard.dart';
import 'package:flutter/material.dart';

class Convert extends StatefulWidget {
  const Convert({super.key});

  @override
  State<Convert> createState() => _ConvertState();
}

class _ConvertState extends State<Convert> {
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
