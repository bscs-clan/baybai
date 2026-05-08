import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class CustomIconButton extends StatelessWidget {
  final String? svgAsset;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double iconSize;
  final bool isActive;

  const CustomIconButton({
    super.key,
    this.svgAsset,
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
      side: svgAsset == null
          ? BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 4)
          : BorderSide.none,
    );

    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: svgAsset == null
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
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset!,
                    colorFilter: ColorFilter.mode(
                      isActive ? Colors.black : Colors.white,
                      BlendMode.srcIn,
                    ),
                    width: iconSize,
                    height: iconSize,
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
