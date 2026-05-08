import "package:baybai/core/configs/theme/colors.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool("onboardingSeen") ?? false;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, seen ? "/home" : "/onboarding");
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Image.asset(
              "assets/images/ic_logo.png",
              width: 140,
              height: 140,
            ),
          ),
          Spacer(),
          Text(
            "BaybAI",
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkText : AppColors.text,
            ),
          ),
          Text(
            "Scan, Transliterate, Learn",
            style: TextStyle(
              color: isDarkMode ? AppColors.darkTextGrey : AppColors.textGrey,
            ),
          ),
          SizedBox(height: 64),
        ],
      ),
    );
  }
}
