import "dart:async";

import "package:admonitions/admonitions.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:baybai/shared/components/inputs/input.dart";
import "package:baybai/features/auth/domain/exceptions/auth_exception.dart";
import "package:baybai/features/auth/domain/usecases/sign_up.dart";
import "package:baybai/injection_container.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _hasAcceptedTerms = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Timer? _admonitionTimer;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _admonitionTimer?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      _showError("Enter your first and last name.");
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError("Enter your email address to sign up.");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError("Create a password for your account.");
      return;
    }
    if (!_hasAcceptedTerms) {
      _showError("Please accept the Terms and Agreement to sign up.");
      return;
    }
    _admonitionTimer?.cancel();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await serviceLoc<SignUp>()(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;

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
                        "Sign Up",
                        style: AppTextStyles.boldXl.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create an account and start learning Baybayin.",
                        style: AppTextStyles.regularSm.copyWith(
                          color: isDarkMode
                              ? AppColors.gray40
                              : AppColors.gray70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 56),
                      Input(
                        hintText: "First Name",
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 8),
                      Input(
                        hintText: "Last Name",
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 8),
                      Input(
                        hintText: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 8),
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
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _hasAcceptedTerms,
                              activeColor: AppColors.primary60,
                              onChanged: (value) {
                                setState(() {
                                  _hasAcceptedTerms = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _hasAcceptedTerms = !_hasAcceptedTerms;
                                  });
                                },
                                child: Text(
                                  "I agree to the Terms and Agreement",
                                  style: AppTextStyles.regularXs.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Button(
                        onTap: _isSubmitting ? null : _signUp,
                        width: double.infinity,
                        label: "Sign Up",
                        isLoading: _isSubmitting,
                        size: ButtonSize.md,
                        height: 48,
                        customBackgroundColor: AppColors.primary60,
                        customForegroundColor: AppColors.gray10,
                        textStyle: AppTextStyles.boldSm,
                      ),
                      const SizedBox(height: 32),
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
