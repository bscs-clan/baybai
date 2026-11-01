import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/buttons/button.dart";
import "package:admonitions/admonitions.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";

class PracticeFeedbackAdmonition extends StatelessWidget {
  final String feedback;
  final bool? isCorrect;

  const PracticeFeedbackAdmonition({
    super.key,
    required this.feedback,
    required this.isCorrect,
  });

  Color get _feedbackColor => isCorrect == true
      ? AppColors.bgSuccessContrast
      : AppColors.bgErrorContrast;

  Color get _feedbackBackgroundColor =>
      isCorrect == true ? AppColors.bgSuccess : AppColors.bgError;

  @override
  Widget build(BuildContext context) {
    return SolidAdmonition(
      color: _feedbackBackgroundColor,
      icon: HugeIcon(
        icon: isCorrect == true
            ? HugeIcons.strokeRoundedParty
            : HugeIcons.strokeRoundedTired02,
        size: 18,
        color: _feedbackColor,
      ),
      child: Text(
        feedback,
        style: AppTextStyles.regularSm.copyWith(color: _feedbackColor),
      ),
    );
  }
}

class PracticeActionFooter extends StatelessWidget {
  final bool? isCorrect;
  final bool isChecking;
  final VoidCallback onCheck;
  final VoidCallback onTryAgain;

  const PracticeActionFooter({
    super.key,
    required this.isCorrect,
    required this.isChecking,
    required this.onCheck,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: isCorrect != null
          ? Button(
              label: "Try Again",
              onTap: onTryAgain,
              type: ButtonType.outline,
              customBorderColor: AppColors.gray20,
              width: double.infinity,
            )
          : Button(
              label: isChecking ? "Checking" : "Check",
              onTap: isChecking ? null : onCheck,
              type: ButtonType.primary,
              customBackgroundColor: AppColors.primary60,
              width: double.infinity,
            ),
    );
  }
}
