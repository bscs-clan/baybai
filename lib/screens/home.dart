import 'package:baybai/components/learncard.dart';
import 'package:baybai/components/theme/colors.dart';
import 'package:baybai/components/theme/text.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mabuhay, Deobert', style: AppTextStyles.body),
            SizedBox(height: 12),
            Text('Ready to learn Baybayin?', style: AppTextStyles.heading),
            SizedBox(height: 24),
            LearnCard(),
          ],
        ),
      ),
    );
  }
}
