import "dart:async";

import "package:admonitions/admonitions.dart";
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
  bool _isContinuingAsGuest = false;
  String? _errorMessage;
  Timer? _admonitionTimer;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _admonitionTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    _admonitionTimer?.cancel();
    setState(() => _errorMessage = message);
    _admonitionTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (_emailController.text.trim().isEmpty) {
      _showError("Enter your email address to log in.");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError("Enter your password to log in.");
      return;
    }
    _admonitionTimer?.cancel();
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
      _showError(error.message);
    } catch (_) {
      _showError("Unable to connect to the server.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _continueAsGuest() {
    FocusScope.of(context).unfocus();
    setState(() => _isContinuingAsGuest = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.gray100 : AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        "Log In",
                        style: AppTextStyles.boldXl.copyWith(
                          color: isDarkMode
                              ? AppColors.gray10
                              : AppColors.gray100,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Learn Baybayin, one step at a time.",
                        style: AppTextStyles.regularSm.copyWith(
                          color: isDarkMode
                              ? AppColors.gray40
                              : AppColors.gray70,
                        ),
                        textAlign: TextAlign.center,
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
                      Button(
                        onTap: _isSubmitting ? null : _signIn,
                        width: double.infinity,
                        label: "Log In",
                        isLoading: _isSubmitting,
                        size: ButtonSize.md,
                        height: 48,
                        customBackgroundColor: AppColors.primary60,
                        customForegroundColor: AppColors.gray10,
                        textStyle: AppTextStyles.boldSm,
                      ),
                      const SizedBox(height: 12),
                      Button(
                        onTap: (_isSubmitting || _isContinuingAsGuest)
                            ? null
                            : _continueAsGuest,
                        width: double.infinity,
                        label: "Continue as Guest",
                        isLoading: _isContinuingAsGuest,
                        size: ButtonSize.md,
                        height: 48,
                        type: ButtonType.primary,
                        customBackgroundColor: AppColors.primary20,
                        customForegroundColor: AppColors.primary60,
                        textStyle: AppTextStyles.boldSm,
                      ),

                      const SizedBox(height: 32),

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
            if (_errorMessage != null)
              Positioned(
                top: 0,
                left: 32,
                right: 32,
                child: SolidAdmonition.danger(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedAlertCircle,
                    size: 18,
                    color: AppColors.white,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.regularSm.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
