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
  bool _isSubmitting = false;
  String? _errorMessage;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Enter your first and last name.");
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Enter your email address to sign up.");
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Create a password for your account.");
      return;
    }
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
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = "Unable to connect to the server.");
      }
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
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: _errorMessage == null
                              ? null
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: SolidAdmonition.danger(
                                    icon: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedAlertCircle,
                                      size: 18,
                                      color: AppColors.white,
                                    ),
                                    child: Flexible(
                                      child: Text(
                                        _errorMessage!,
                                        style: AppTextStyles.regularSm.copyWith(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
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
