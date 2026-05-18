import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:introduction_screen/introduction_screen.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboardingSeen", true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? AppColors.darkText : AppColors.text;
    final bodyColor = isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey;

    Widget onboardingImage(String assetName) {
      return Center(
        child: Opacity(
          opacity: isDarkMode ? 0.80 : 1,
          child: Image.asset(
            "assets/images/$assetName",
            fit: BoxFit.contain,
            height: 260,
          ),
        ),
      );
    }

    final pageDecoration = PageDecoration(
      titleTextStyle: AppTextStyles.bigbody.copyWith(
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      bodyTextStyle: AppTextStyles.body.copyWith(color: bodyColor),
      bodyAlignment: Alignment.center,
      titlePadding: const EdgeInsets.only(top: 16, bottom: 12),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
      imagePadding: const EdgeInsets.only(top: 40),
      pageColor: Colors.transparent,
    );

    final pageSteps = [
      PageViewModel(
        title: "Learn Baybayin Script",
        body:
            "Discover the ancient Filipino writing system through interactive lessons, character guides, and easy-to-follow examples.",
        image: onboardingImage("illus_waving.png"),
        decoration: pageDecoration,
      ),

      PageViewModel(
        title: "Transliterate to Filipino",
        body:
            "Convert modern Filipino words and phrases into Baybayin instantly with beginner-friendly transliteration.",
        image: onboardingImage("illus_reading.png"),
        decoration: pageDecoration,
      ),

      PageViewModel(
        title: "Getting Started",
        body:
            "Practice writing, improve your reading skills, and begin exploring Filipino culture through Baybayin today.",
        image: onboardingImage("illus_eating.png"),
        decoration: pageDecoration,
      ),
    ];

    final overlayStyle =
        Theme.of(context).appBarTheme.systemOverlayStyle ??
        (isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          child: IntroductionScreen(
            pages: pageSteps,

            showSkipButton: true,

            skip: Text(
              "SKIP",
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            next: Text(
              "NEXT",
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            done: Text(
              "DONE",
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            onDone: _completeOnboarding,
            onSkip: _completeOnboarding,

            dotsDecorator: DotsDecorator(
              size: const Size.square(8),
              activeSize: const Size(20, 8),
              activeColor: AppColors.primary,
              color: AppColors.primary.withAlpha(100),
              spacing: const EdgeInsets.symmetric(horizontal: 3),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
