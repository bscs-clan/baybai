import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:introduction_screen/introduction_screen.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:baybai/core/configs/theme/colors.dart";

final pageSteps = [
  PageViewModel(
    title: "Learn Baybayin script",
    bodyWidget: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    image: const Center(child: Icon(Icons.android)),
  ),
  PageViewModel(
    title: "Transliterate to Filipino",
    bodyWidget: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    image: const Center(child: Icon(Icons.android)),
  ),
  PageViewModel(
    title: "Getting Started",
    bodyWidget: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    image: const Center(child: Icon(Icons.android)),
  ),
];

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
    final overlayStyle =
        Theme.of(context).appBarTheme.systemOverlayStyle ??
        (Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: SafeArea(
          child: IntroductionScreen(
            pages: pageSteps,
            showSkipButton: true,
            skip: const Text(
              "SKIP",
              style: TextStyle(color: AppColors.primary),
            ),
            next: const Text(
              "NEXT",
              style: TextStyle(color: AppColors.primary),
            ),
            done: const Text(
              "DONE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
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
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
