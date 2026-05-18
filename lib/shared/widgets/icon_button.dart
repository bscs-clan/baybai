import "package:flutter/material.dart";

class CustomIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double iconSize;
  final bool isActive;

  const CustomIconButton({
    super.key,
    this.icon,
    required this.onPressed,
    required this.width,
    required this.height,
    this.iconSize = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(22),
      side: icon == null
          ? BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 4)
          : BorderSide.none,
    );

    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: icon == null
            ? Colors.transparent
            : (isActive
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.5)),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: isActive ? Colors.black : Colors.white,
                    size: iconSize,
                  )
                : Container(
                    width: width - 16,
                    height: height - 16,
                    decoration: ShapeDecoration(
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
