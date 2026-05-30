import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";

enum InputSize { sm, md, lg }

class Input extends StatefulWidget {
  final IconData leftIcon;
  final IconData? rightIcon;
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onRightIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final InputSize size;

  const Input({
    super.key,
    required this.leftIcon,
    this.rightIcon,
    required this.hintText,
    this.controller,
    this.onRightIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.size = InputSize.md,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    late final double height;
    late final double horizontalPadding;
    late final double iconSize;
    late final double borderRadius;
    late final double fontSize;

    switch (widget.size) {
      case InputSize.sm:
        height = 40;
        horizontalPadding = 12;
        iconSize = 18;
        borderRadius = 12;
        fontSize = 14;
        break;

      case InputSize.md:
        height = 48;
        horizontalPadding = 14;
        iconSize = 22;
        borderRadius = 14;
        fontSize = 16;
        break;

      case InputSize.lg:
        height = 56;
        horizontalPadding = 16;
        iconSize = 24;
        borderRadius = 18;
        fontSize = 18;
        break;
    }

    Color borderColor;

    if (_isFocused) {
      borderColor = AppColors.primary;
    } else {
      borderColor = isDarkMode ? Colors.white24 : Colors.black12;
    }

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkInputBackground
            : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Icon(
            widget.leftIcon,
            size: iconSize,
            color: _isFocused ? AppColors.primary : Colors.grey[600],
          ),
          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: fontSize),
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isCollapsed: true,
                hintStyle: TextStyle(fontSize: fontSize),
              ),
            ),
          ),

          if (widget.rightIcon != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onRightIconTap,
              child: Icon(
                widget.rightIcon,
                size: iconSize,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
