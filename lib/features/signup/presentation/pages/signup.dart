import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/inputs/input.dart";
import "package:flutter/material.dart";
import "package:solar_icons/solar_icons.dart";

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.darkBackground
          : AppColors.background,
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
                          "Create Account",
                          style: AppTextStyles.heading.copyWith(
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 56),
                        Input(
                          leftIcon: SolarIconsBold.user,
                          hintText: "Name",
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 8),
                        Input(
                          leftIcon: SolarIconsBold.letter,
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 8),
                        Input(
                          leftIcon: SolarIconsBold.lockKeyhole,
                          hintText: "Password",
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        Button(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, "/home"),
                          width: double.infinity,
                          label: "Sign Up",
                          size: ButtonSize.md,
                        ),
                        const Spacer(),
                        const SizedBox(height: 56),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: AppTextStyles.body.copyWith(
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushReplacementNamed(context, "/login"),
                              child: Text(
                                "Sign In",
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primary,
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
