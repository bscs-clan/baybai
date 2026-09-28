import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/inputs/input.dart";
import "package:flutter/material.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
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
                          "Sign In",
                          style: AppTextStyles.heading.copyWith(
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 56),
                        Input(
                          leftIcon: Icons.email,
                          hintText: "Email",
                        ),
                        const SizedBox(height: 8),
                        Input(
                          leftIcon: Icons.lock,
                          hintText: "Password",
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        Button(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "/home");
                          },
                          width: double.infinity,
                          label: "Sign In",
                          size: ButtonSize.md,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Forgot password?",
                              style: AppTextStyles.body.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, "/signup"),
                              child: Text(
                                "Recover",
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),
                        const SizedBox(height: 56),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppTextStyles.body.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, "/signup"),
                              child: Text(
                                "Sign Up",
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
