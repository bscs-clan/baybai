import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const CustomIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: shadcn.Button(
        onPressed: onTap,
        style: shadcn.ButtonStyle.ghostIcon(
          size: shadcn.ButtonSize.normal,
          shape: shadcn.ButtonShape.rectangle,
        ).withPadding(padding: EdgeInsets.zero),
        child: Icon(
          icon,
          size: 24,
          color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
        ),
      ),
    );
  }
}
