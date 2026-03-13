import 'package:baybai/components/explore.dart';
import 'package:baybai/components/learningcard.dart';
import 'package:baybai/components/theme/colors.dart';
import 'package:baybai/components/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                
                Text('Mabuhay, Deobert', style: AppTextStyles.heading),
                SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/hand-shake.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.dark,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Ready to learn Baybayin?', style: AppTextStyles.body),
            SizedBox(height: 24),
            LearningCard(progress: 0.0, onPressed: () {}),
            SizedBox(height: 24),
            Text('Explore', style: AppTextStyles.bigheader),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightgrey),
              ),
              child: Column(
                children: [
                  Explore(
                    icon: 'assets/icons/character.svg',
                    title: "Character",
                    onTap: () {},
                  ),

                  Divider(height: 1),

                  Explore(
                    icon: 'assets/icons/scanner.svg',
                    title: "AR Scan",
                    onTap: () {},
                  ),

                  Divider(height: 1),

                  Explore(
                    icon: 'assets/icons/translate.svg',
                    title: "Translate",
                    onTap: () {},
                  ),

                  Divider(height: 1),

                  Explore(
                    icon: 'assets/icons/quiz.svg',
                    title: "Quiz",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
