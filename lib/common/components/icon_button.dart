import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatelessWidget {
  final String svgAsset;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double iconSize;
  final bool isActive;

  const CustomIconButton({
    super.key,
    required this.svgAsset,
    required this.onPressed,
    required this.width,
    required this.height,
    this.iconSize = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: isActive
            ? Colors.white.withValues(alpha: 0.8)
            : Colors.black.withValues(alpha: 0.5),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: Center(
            child: SvgPicture.asset(
              svgAsset,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.black : Colors.white,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
