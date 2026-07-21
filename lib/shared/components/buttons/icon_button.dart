import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

class CustomIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final double size;
  final double? iconSize;
  final Color? color;
  final Color? iconColor;

  const CustomIconButton({
    super.key,
    this.icon,
    this.child,
    required this.onTap,
    this.size = 48.0,
    this.iconSize,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    assert(
      (icon != null) ^ (child != null),
      'Provide either icon or child, not both',
    );
    final radius = BorderRadius.circular(size * (64.0 / 48.0));
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? (isDarkMode ? AppColors.darkBox : AppColors.box),
          borderRadius: radius,
        ),
        child: shadcn.Button(
          onPressed: onTap,
          style: shadcn.ButtonStyle.ghostIcon(
            size: shadcn.ButtonSize.normal,
            shape: shadcn.ButtonShape.rectangle,
          ).withPadding(padding: EdgeInsets.zero),
          child:
              child ??
              Icon(
                icon!,
                size: iconSize ?? 24.0,
                color:
                    iconColor ??
                    (isDarkMode ? AppColors.darkText : AppColors.icon),
              ),
        ),
      ),
    );
  }
}
