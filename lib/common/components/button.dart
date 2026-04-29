import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

enum ButtonType { primary, secondary, outline }

class Button extends StatelessWidget {
  final String label;
  final String? iconPath;
  final String? rightIconPath;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onTap;
  final ButtonType type;
  final double? width;

  const Button({
    super.key,
    required this.label,
    this.iconPath,
    this.rightIconPath,
    this.leftIcon,
    this.rightIcon,
    this.onTap,
    this.type = ButtonType.primary,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isEnabled = onTap != null;

    final bool isPrimary = type == ButtonType.primary;
    final bool isSecondary = type == ButtonType.secondary;

    Color getTextColor() {
      if (isPrimary) {
        return isDarkMode ? AppColors.text : AppColors.white;
      } else if (isSecondary) {
        return AppColors.text;
      } else {
        return AppColors.white;
      }
    }

    Widget buttonContent = Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: ShapeDecoration(
            color: isPrimary
                ? AppColors.primary
                : (isSecondary ? AppColors.white : Colors.transparent),
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(18),
              side: isPrimary || isSecondary
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
            mainAxisSize: width == double.infinity
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leftIcon != null) ...[
                Icon(leftIcon, size: 20, color: getTextColor()),
                const SizedBox(width: 8),
              ],
              if (iconPath != null) ...[
                SvgPicture.asset(
                  iconPath!,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    getTextColor(),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.wbody.copyWith(
                  color: getTextColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (rightIconPath != null) ...[
                const SizedBox(width: 8),
                SvgPicture.asset(
                  rightIconPath!,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    getTextColor(),
                    BlendMode.srcIn,
                  ),
                ),
              ],
              if (rightIcon != null) ...[
                const SizedBox(width: 8),
                Icon(rightIcon, size: 20, color: getTextColor()),
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
