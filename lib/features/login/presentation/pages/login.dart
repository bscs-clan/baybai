import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/auth/domain/exceptions/auth_exception.dart";
import "package:baybai/features/auth/domain/usecases/sign_in.dart";
import "package:baybai/injection_container.dart";
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
  bool _isSubmitting = false;
  String? _errorMessage;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await serviceLoc<SignIn>()(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = "Unable to connect to the server.");
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _continueAsGuest() {
    FocusScope.of(context).unfocus();
    Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.gray100 : AppColors.bg,
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
                                ? AppColors.gray10
                                : AppColors.gray100,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Learn Baybayin, one step at a time.",
                          style: AppTextStyles.regularSm.copyWith(
                            color: isDarkMode
                                ? AppColors.gray40
                                : AppColors.gray70,
                          ),
                        ),

                        const SizedBox(height: 56),
                        Input(
                          hintText: "Email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        Input(
                          rightIcon: _isPasswordVisible
                              ? HugeIcons.strokeRoundedViewOff
                              : HugeIcons.strokeRoundedView,
                          hintText: "Password",
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
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
                                style: AppTextStyles.regularSm.copyWith(
                                  color: AppColors.primary60,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: AppTextStyles.regularSm.copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Button(
                          onTap: _isSubmitting ? null : _signIn,
                          width: double.infinity,
                          label: "Log In",
                          size: ButtonSize.md,
                          height: 48,
                          customBackgroundColor: AppColors.primary60,
                          customForegroundColor: AppColors.gray10,
                          textStyle: AppTextStyles.boldSm,
                        ),
                        const SizedBox(height: 12),
                        Button(
                          onTap: _isSubmitting ? null : _continueAsGuest,
                          width: double.infinity,
                          label: "Continue as Guest",
                          size: ButtonSize.md,
                          height: 48,
                          type: ButtonType.primary,
                          customBackgroundColor: AppColors.primary20,
                          customForegroundColor: AppColors.primary60,
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
                                    ? AppColors.gray10
                                    : AppColors.gray100,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, "/signup"),
                              child: Text(
                                "Sign Up",
                                style: AppTextStyles.regularSm.copyWith(
                                  color: AppColors.primary60,
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
