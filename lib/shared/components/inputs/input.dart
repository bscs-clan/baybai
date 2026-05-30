import "package:baybai/core/theme/colors.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

enum InputSize { sm, md, lg }

class Input extends StatefulWidget {
  final IconData? leftIcon;
  final IconData? rightIcon;
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onRightIconTap;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final InputSize size;

  const Input({
    super.key,
    this.leftIcon,
    this.rightIcon,
    required this.hintText,
    this.controller,
    this.onRightIconTap,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.size = InputSize.md,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode()
      ..addListener(() {
        if (!mounted) return;
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _InputMetrics.fromSize(widget.size);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final borderColor = _isFocused
        ? AppColors.primary
        : (isDarkMode ? Colors.white24 : Colors.black12);

    final iconColor = _isFocused
        ? AppColors.primary
        : (isDarkMode ? AppColors.darkIcon : AppColors.icon);

    return AnimatedContainer(
      duration: ComponentMotion.fast,
      height: metrics.height,
      decoration: BoxDecoration(
        color: ComponentColors.inputSurface(context),
        borderRadius: BorderRadius.circular(metrics.borderRadius),
        border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1),
      ),
      child: Row(
        children: [
          if (widget.leftIcon != null)
            Padding(
              padding: EdgeInsets.only(left: metrics.horizontalPadding),
              child: Icon(
                widget.leftIcon,
                size: metrics.iconSize,
                color: iconColor,
              ),
            ),

          if (widget.leftIcon != null)
            SizedBox(width: metrics.horizontalPadding),

          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,

              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: metrics.fontSize),

              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          if (widget.rightIcon != null)
            Padding(
              padding: EdgeInsets.only(right: metrics.horizontalPadding),
              child: shadcn.Button(
                onPressed: widget.onRightIconTap,
                style: shadcn.ButtonStyle.ghostIcon(
                  size: shadcn.ButtonSize.small,
                ).withPadding(padding: EdgeInsets.zero),
                child: Icon(
                  widget.rightIcon,
                  size: metrics.iconSize,
                  color: iconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InputMetrics {
  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double borderRadius;
  final double fontSize;

  const _InputMetrics({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
    required this.borderRadius,
    required this.fontSize,
  });

  factory _InputMetrics.fromSize(InputSize size) {
    return switch (size) {
      InputSize.sm => const _InputMetrics(
        height: 40,
        horizontalPadding: 12,
        iconSize: 18,
        borderRadius: ComponentRadius.sm,
        fontSize: 14,
      ),
      InputSize.md => const _InputMetrics(
        height: 48,
        horizontalPadding: 14,
        iconSize: 22,
        borderRadius: ComponentRadius.md,
        fontSize: 16,
      ),
      InputSize.lg => const _InputMetrics(
        height: 56,
        horizontalPadding: 16,
        iconSize: 24,
        borderRadius: ComponentRadius.lg,
        fontSize: 18,
      ),
    };
  }
}
