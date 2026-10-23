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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    final nameParts = _nameController.text.trim().split(RegExp(r"\s+"));
    if (nameParts.length < 2 || nameParts.any((part) => part.isEmpty)) {
      setState(() => _errorMessage = "Enter your first and last name.");
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await serviceLoc<SignUp>()(
        firstName: nameParts.first,
        lastName: nameParts.skip(1).join(" "),
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
                          hintText: "Name",
                          controller: _nameController,
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
                          onTap: _isSubmitting ? null : _signUp,
                          width: double.infinity,
                          label: "Sign Up",
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
