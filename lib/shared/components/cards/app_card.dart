import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
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
    this.borderColor,
    this.boxShadow,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = SizedBox(
      width: width,
      height: height,
      child: shadcn.SurfaceCard(
        padding: padding,
        filled: true,
        fillColor: backgroundColor ?? ComponentColors.surface(context),
        borderColor: borderColor ?? ComponentColors.border(context),
        borderWidth: 1,
        borderRadius: borderRadius ?? BorderRadius.circular(ComponentRadius.md),
        boxShadow: boxShadow,
        child: child,
      ),
    );

    if (onTap == null) return card;

    return shadcn.Button(
      style: shadcn.ButtonStyle.card()
          .withPadding(padding: EdgeInsets.zero)
          .withBackgroundColor(color: Colors.transparent)
          .withBorder(border: Border.all(color: Colors.transparent)),
      onPressed: onTap,
      child: card,
    );
  }
}
