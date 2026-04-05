import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

enum ButtonType { primary, outline }

class Button extends StatelessWidget {
  final String label;
  final String? iconPath;
  final VoidCallback onTap;
  final ButtonType type;

  const Button({
    super.key,
    required this.label,
    this.iconPath,
    required this.onTap,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bool isPrimary = type == ButtonType.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: ShapeDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: AppColors.dark, width: 1),
          ),
          shadows: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    spreadRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.wbody.copyWith(
                color: isPrimary
                    ? (isDarkMode ? AppColors.text : AppColors.darkText)
                    : AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (iconPath != null) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(
                iconPath!,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isPrimary
                      ? (isDarkMode ? AppColors.text : AppColors.darkText)
                      : AppColors.darkText,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
