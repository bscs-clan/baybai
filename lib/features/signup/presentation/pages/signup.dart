import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/inputs/input.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.text;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
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
                          "Sign Up",
                          style: AppTextStyles.boldXl.copyWith(
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create an account and start learning Baybayin.",
                          style: AppTextStyles.regularSm.copyWith(
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.grey6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 56),
                        Input(
                          hintText: "Name",
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 8),
                        Input(
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 8),
                        Input(
                          rightIcon: _isPasswordVisible
                              ? HugeIcons.strokeRoundedViewOff
                              : HugeIcons.strokeRoundedView,
                          hintText: "Password",
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onRightIconTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Button(
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, "/home"),
                          width: double.infinity,
                          label: "Sign Up",
                          size: ButtonSize.md,
                          height: 48,
                          customBackgroundColor: AppColors.blue6,
                          textStyle: AppTextStyles.boldSm,
                        ),
                        const Spacer(),
                        const SizedBox(height: 56),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Have an account?",
                              style: AppTextStyles.regularSm.copyWith(
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                "/login",
                              ),
                              child: Text(
                                "Log In",
                                style: AppTextStyles.regularSm.copyWith(
                                  color: AppColors.blue6,
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
