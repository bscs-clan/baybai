import "package:flutter/material.dart";
import "package:baybai/shared/components/base/component_tokens.dart";

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ComponentSpacing.lg),
    this.onTap,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : BorderRadius.circular(ComponentRadius.md);

    final card = Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: backgroundColor ?? ComponentColors.surface(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: resolvedRadius,
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
        shadows: boxShadow,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: resolvedRadius, onTap: onTap, child: card),
    );
  }
}
