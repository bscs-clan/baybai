import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/home/presentation/pages/home.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/inputs/input.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const SizedBox(height: 56),
                        Text(
                          "Log In",
                          style: AppTextStyles.boldXl.copyWith(
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.grey10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Learn Baybayin, one step at a time.",
                          style: AppTextStyles.regularSm.copyWith(
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.grey6,
                          ),
                        ),

                        const SizedBox(height: 56),
                        Input(hintText: "Email"),
                        const SizedBox(height: 12),
                        Input(
                          rightIcon: _isPasswordVisible
                              ? HugeIcons.strokeRoundedViewOff
                              : HugeIcons.strokeRoundedView,
                          hintText: "Password",
                          obscureText: !_isPasswordVisible,
                          onRightIconTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, "/signup"),
                              child: Text(
                                "Forgot password?",
                                style: AppTextStyles.boldSm.copyWith(
                                  color: AppColors.blue9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Button(
                          onTap: () {
                            Navigator.pushReplacement<void, void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                          width: double.infinity,
                          label: "Log In",
                          size: ButtonSize.md,
                          height: 48,
                          customBackgroundColor: AppColors.blue9,
                          textStyle: AppTextStyles.boldSm,
                        ),

                        const Spacer(),
                        const SizedBox(height: 56),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppTextStyles.regularSm.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.grey10,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, "/signup"),
                              child: Text(
                                "Sign Up",
                                style: AppTextStyles.regularSm.copyWith(
                                  color: AppColors.blue9,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
