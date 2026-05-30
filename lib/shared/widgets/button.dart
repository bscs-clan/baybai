import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";

enum ButtonType { primary, secondary, outline }

enum ButtonSize { sm, md, lg }

class Button extends StatelessWidget {
  final String label;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onTap;
  final ButtonType type;
  final ButtonSize size;
  final double? width;

  const Button({
    super.key,
    required this.label,
    this.leftIcon,
    this.rightIcon,
    this.onTap,
    this.type = ButtonType.primary,
    this.size = ButtonSize.md,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isEnabled = onTap != null;

    final bool isPrimary = type == ButtonType.primary;
    final bool isSecondary = type == ButtonType.secondary;

    Color getTextColor() {
      if (isPrimary) {
        return isDarkMode ? AppColors.text : AppColors.white;
      } else if (isSecondary) {
        return isDarkMode ? AppColors.darkWhite : AppColors.text;
      } else {
        return isDarkMode ? AppColors.darkWhite : AppColors.text;
      }
    }

    late final double horizontalPadding;
    late final double verticalPadding;
    late final double iconSize;
    late final double borderRadius;
    late final TextStyle textStyle;

    switch (size) {
      case ButtonSize.sm:
        horizontalPadding = 14;
        verticalPadding = 12;
        iconSize = 16;
        borderRadius = 14;
        textStyle = AppTextStyles.wbody.copyWith(
          fontWeight: FontWeight.bold,
          color: getTextColor(),
        );
        break;

      case ButtonSize.md:
        horizontalPadding = 18;
        verticalPadding = 16;
        iconSize = 20;
        borderRadius = 18;
        textStyle = AppTextStyles.wbody.copyWith(
          fontWeight: FontWeight.bold,
          color: getTextColor(),
        );
        break;

      case ButtonSize.lg:
        horizontalPadding = 24;
        verticalPadding = 20;
        iconSize = 24;
        borderRadius = 22;
        textStyle = AppTextStyles.wbody.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: getTextColor(),
        );
        break;
    }

    Widget buttonContent = Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: ShapeDecoration(
            color: isPrimary
                ? AppColors.primary
                : (isSecondary
                      ? (isDarkMode ? AppColors.darkCompBg : AppColors.white)
                      : Colors.transparent),
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: isPrimary || isSecondary
                  ? BorderSide.none
                  : BorderSide(
                      color: isDarkMode ? AppColors.darkWhite : AppColors.dark,
                      width: 1,
                    ),
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
            mainAxisSize: width == double.infinity
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leftIcon != null) ...[
                Icon(leftIcon, size: iconSize, color: getTextColor()),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle),
              if (rightIcon != null) ...[
                const SizedBox(width: 8),
                Icon(rightIcon, size: iconSize, color: getTextColor()),
              ],
            ],
          ),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: buttonContent);
    }

    return buttonContent;
  }
}
