import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

enum InputSize { sm, md, lg }

class Input extends StatefulWidget {
  final Object? leftIcon;
  final Object? rightIcon;
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
        ? AppColors.primary60
        : (isDarkMode ? AppColors.gray80 : AppColors.gray20);

    final iconColor = isDarkMode ? AppColors.gray30 : AppColors.gray60;
    final inputTextStyle = AppTextStyles.regularSm.copyWith(
      color: isDarkMode ? AppColors.gray10 : AppColors.gray100,
    );

    return AnimatedContainer(
      duration: ComponentMotion.fast,
      height: metrics.height,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gray90 : AppColors.bg,
        borderRadius: BorderRadius.circular(metrics.borderRadius),
        border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary60.withValues(alpha: 0.3),
                  spreadRadius: 3,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.leftIcon != null)
            Padding(
              padding: EdgeInsets.only(left: metrics.horizontalPadding),
              child: _buildInputIcon(
                widget.leftIcon!,
                metrics.iconSize,
                iconColor,
              ),
            ),

          if (widget.leftIcon != null)
            SizedBox(width: metrics.horizontalPadding),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                enabled: widget.enabled,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                cursorColor: AppColors.primary60,
                style: inputTextStyle,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: inputTextStyle.copyWith(
                    color: isDarkMode ? AppColors.gray50 : AppColors.gray60,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
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
                child: _buildInputIcon(
                  widget.rightIcon!,
                  metrics.iconSize,
                  iconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildInputIcon(Object icon, double size, Color color) {
  if (icon is IconData) {
    return Icon(icon, size: size, color: color);
  }
  if (icon is List<List<dynamic>>) {
    return HugeIcon(icon: icon, size: size, color: color);
  }
  throw ArgumentError.value(icon, 'icon', 'Unsupported input icon type');
}

class _InputMetrics {
  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double borderRadius;

  const _InputMetrics({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
    required this.borderRadius,
  });

  factory _InputMetrics.fromSize(InputSize size) {
    return switch (size) {
      InputSize.sm => const _InputMetrics(
        height: 40,
        horizontalPadding: 12,
        iconSize: 24,
        borderRadius: ComponentRadius.sm,
      ),
      InputSize.md => const _InputMetrics(
        height: 48,
        horizontalPadding: 14,
        iconSize: 24,
        borderRadius: ComponentRadius.xs,
      ),
      InputSize.lg => const _InputMetrics(
        height: 56,
        horizontalPadding: 16,
        iconSize: 24,
        borderRadius: ComponentRadius.lg,
      ),
    };
  }
}
